# share-path.el

Share your current buffer path to external tools.

## Usage

Install and enable the mode, for example:

```emacs-lisp
(use-package share-path
  :straight (:type git :host nil :repo "https://codeberg.org/purplg/share-path.el")
  :init
  (share-path-mode))
```

External program can read from the path defined in `share-path-path`. By default, this path is `/tmp/emacs-share-path`.

To automatically start newly spawned terminals in the directory of your project, add this to your
.bashrc or equivalent bash-compatible shell:

```bash
[[ -f "/tmp/emacs-share-path" ]] \
  && [[ -d "$(cat /tmp/emacs-share-path)" ]] \
  && cd "$(cat /tmp/emacs-share-path)"
```
