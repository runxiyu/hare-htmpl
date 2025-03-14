# hare-htmpl – A simple HTML templating engine

This is a Hare port of the HTML templating engine used in
[Got](https://got.gameoftrees.org/?action=summary&path=got.git)
and described in
[Omar Polo's blog post](https://www.omarpolo.com/post/template.html).

The `htmplgen` program generates a Hare file from the template file.

The `htmpl` module provides auxiliary functions used by the generated Hare
code, and must be installed for the generated code to compile.

Each template is presented as a function that accepts an `io::handle` and
other user-defined parameters, if any. The template writes to that
`io::handle`; this allows for a variety of output backends (i.e. you
could use a `memio`/`bufio` stream, or write to an actual
file/socket/pipe socket, etc.)

## Repository migration notice

The primary repository has been
[migrated onto the Lindenii Project's forge](https://forge.lindenii.runxiyu.org/hare/:/repos/hare-htmpl/).

## Dependencies

- [Hare](https://harelang.org)
- A POSIX-compatible Yacc implementation, such as
  [Bison](https://www.gnu.org/software/bison/)
- A C compiler

## License

This inherits the ISC license from the original code. See the LICENSE file.

## Contributing

Create a branch that begins with `contrib/` and push to the
[main repo](https://forge.lindenii.runxiyu.org/hare/:/repos/hare-htmpl/)
via SSH directly.

```
git clone ssh://forge.lindenii.runxiyu.org/hare/:/repos/hare-htmpl/
cd hare-htmpl
git checkout -b contrib/whatever
# edit and commit stuff
git push -u origin HEAD
```

## Support

[`#chat`](https://webirc.runxiyu.org/kiwiirc/#chat)
on
[irc.runxiyu.org](https://irc.runxiyu.org/).
