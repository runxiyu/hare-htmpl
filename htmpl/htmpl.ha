use io;
use memio;
use strings;

// export type template = struct {
// 	writer: *fn(io::handle, const []u8) (size | io::error),
// };

export fn write(h: io::handle, s: str) (size | io::error) = {
	return io::write(h, strings::toutf8(s))?;
};

export fn write_escape_html(h: io::handle, s: str) (size | io::error | nomem) = {
	let buf = memio::dynamic();
	defer io::close(&buf)!; // TODO: Might not want to abort for syscall interruptions

	let si = strings::iter(s);
	for (true) {
		match (strings::next(&si)) {
		case done =>
			break;
		case let c: rune =>
			switch (c) {
				case '<' =>
					memio::concat(&buf, "&lt;")?;
				case '>' =>
					memio::concat(&buf, "&gt;")?;
				case '&' =>
					memio::concat(&buf, "&amp;")?;
				case '"' =>
					memio::concat(&buf, "&quot;")?;
				case '\'' =>
					memio::concat(&buf, "&apos;")?;
				case =>
					memio::appendrune(&buf, c)?;
			};
		};
	};

	return io::write(h, memio::buffer(&buf))?;
};
