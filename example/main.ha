// SPDX-License-Identifier: CC0-1.0
// By Runxi Yu <https://runxiyu.org>
// Adapted from template by Willow Barraco <contact@willowbarraco.fr>

use errors;
use ev;
use evhttp = ev::http;
use getopt;
use fmt;
use io;
use log;
use memio;
use net;
use net::dial;
use net::http;
use net::ip;
use net::tcp;
use os;
use unix::signal;

type state = struct {
	loop: *ev::loop,
	accept: ev::sockreq,
	clients: []*client,
};

type client = struct {
	state: *state,
	sock: *ev::file,
	httpreq: evhttp::httpreq,
};

const usage: [_]getopt::help = [
	"HTTP server",
	('a', "address", "listened address (ex: 127.0.0.1:8080)"),
];

export fn main() void = {
	const cmd = getopt::parse(os::args, usage...);
	defer getopt::finish(&cmd);

	let port: u16 = 8080;
	let listen_ip: ip::addr = ip::LOCAL_V4;

	for (let opt .. cmd.opts) {
		switch (opt.0) {
		case 'a' =>
			match (dial::splitaddr(opt.1, "")) {
			case let tup: (str, u16) =>
				const v4 = ip::parsev4(tup.0)!;
				listen_ip = v4: ip::addr;
				port = tup.1;
			case dial::invalid_address =>
				log::fatalf("invalid address: {}", opt.1);
			};
		case =>
			abort("unreachable getopt value");
		};
	};

	const loop = ev::newloop()!;
	defer ev::finish(&loop);

	const sock = match (ev::listen_tcp(&loop, listen_ip, port, tcp::reuseaddr)) {
	case let err: net::error =>
		log::fatalf("Error: listen: {}", net::strerror(err));
	case let err: errors::error =>
		log::fatalf("Error: listen: {}", errors::strerror(err));
	case let s: *ev::file =>
		yield s;
	};
	defer ev::close(sock);

	let st = state {
		loop = &loop,
		accept = ev::accept_init(sock),
		clients = [],
	};
	defer {
		free(st.clients);
	};

	ev::req_setuser(&st.accept, &st);
	ev::accept(&st.accept, &on_accept);

	const sig = ev::signal_init(&loop, &st, signal::sig::INT, signal::sig::TERM)!;
	defer ev::signal_finish(&sig);
	ev::handle(&sig, &on_signal);

	log::printfln("Listening on {}:{}", ip::string(listen_ip), port);
	ev::run(&loop)!;
};

fn on_signal(req: *ev::signal, sig: signal::sig, user: nullable *opaque) void = {
	const st = user: *state;

	ev::cancel(&st.accept);

	for (0 != len(st.clients)) {
		client_destroy(st.clients[0]);
	};
};

fn on_accept(req: *ev::sockreq, r: (*ev::file | net::error), user: nullable *opaque) void = {
	const st = user: *state;

	const s = match (r) {
	case let f: *ev::file =>
		yield f;
	case let err: net::error =>
		log::println("accept net error:", net::strerror(err));
		ev::accept(req, &on_accept);
		return;
	};

	const cl = alloc(client {
		state = st,
		sock = s,
		httpreq = evhttp::httpreq_init(s),
	})!;
	ev::req_setuser(&cl.httpreq, cl);
	append(st.clients, cl)!;

	evhttp::request_read(&cl.httpreq, &on_read);

	ev::accept(req, &on_accept);
};

fn client_destroy(cl: *client) void = {
	const st = cl.state;

	for (let i = 0z; i < len(st.clients); i += 1) {
		if (st.clients[i] == cl) {
			delete(st.clients[i]);
			break;
		};
	};

	evhttp::httpreq_finish(&cl.httpreq);
	ev::close(cl.sock);
	free(cl);
};

fn on_read(
	req: *evhttp::httpreq,
	r: (http::request | io::EOF | http::protoerr | io::error),
	user: nullable *opaque,
) void = {
	const cl = user: *client;

	const hreq = match (r) {
	case let q: http::request =>
		yield q;
	case io::EOF =>
		client_destroy(cl);
		return;
	case let err: http::protoerr =>
		log::println("http proto error");
		client_destroy(cl);
		return;
	case let err: io::error =>
		log::println("http io error:", io::strerror(err));
		client_destroy(cl);
		return;
	};

	const file = ev::getfd(cl.sock);
	const (rip, rport) = tcp::peeraddr(file) as (ip::addr, u16);
	log::printfln("{}:{}: {} {}", ip::string(rip), rport, hreq.method, hreq.target.path);

	const resp = http::response {
		version = (1, 1),
		status = http::STATUS_OK,
		reason = "OK",
		body = &memio::dynamic(),
		...
	};
	defer {
		http::header_finish(&resp.header);
		io::close(resp.body)!;
	};

	http::header_add(&resp.header, "Content-Type", "text/html")!;

	tp_index(resp.body)!;

	io::seek(resp.body, 0, io::whence::SET)!;

	evhttp::response_write(&cl.httpreq, &resp, &on_write)!;
};

fn on_write(
	req: *evhttp::httpreq,
	r: (void | http::protoerr | io::error),
	user: nullable *opaque,
) void = {
	const cl = user: *client;

	match (r) {
	case void =>
		void;
	case let err: http::protoerr =>
		log::println("write proto error");
	case let err: io::error =>
		log::println("write io error:", io::strerror(err));
	};

	client_destroy(cl);
};
