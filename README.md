# hare-htmpl – A simple HTML templating engine

This is a portable fork of the HTML templating engine used in
[Got](https://got.gameoftrees.org/?action=summary&path=got.git)
and described in
[Omar Polo's blog post](https://www.omarpolo.com/post/template.html).

The `htmplgen` program generates a Hare file from the template file.

The `htmpl` module provides auxiliary functions used by the generated Hare
code, and must be installed for the generated code to compile.

## Dependencies

- [Hare](https://harelang.org)
- A POSIX-compatible Yacc implementation, such as
  [Bison](https://www.gnu.org/software/bison/)
- A C compiler

## License

This inherits the ISC license from the original code. See the LICENSE file.

## Contributing

Create a branch that begins with `contrib/` and push to the
[main repo](https://forge.runxiyu.org/hare/:/repos/hare-htmpl/)
via SSH directly.

```
git clone ssh://forge.runxiyu.org/hare/:/repos/hare-htmpl/
cd chtmpl
git checkout -b contrib/whatever
# edit and commit stuff
git push -u origin HEAD
```

## Support

[`#chat`](https://webirc.runxiyu.org/kiwiirc/#chat)
on
[irc.runxiyu.org](https://irc.runxiyu.org/).
