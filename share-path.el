;;; share-path.el --- Share your current project path to external tools. -*- lexical-binding: t; -*-

;; Homepage: https://codeberg.org/purplg/share-path.el
;; SPDX-License-Identifier: MIT
;;; Commentary:

;; Usage:

;; Just enable the mode and external program can read from the path defined in
;; `share-path-path'.

;; For example, to automatically start newly spawned terminals in the directory of your
;; project, add this to your .bashrc:

;  [[ -f "/tmp/emacs-share-path" ]] \
;  && [[ -d "$(cat /tmp/emacs-share-path)" ]] \
;  && cd "$(cat /tmp/emacs-share-path)"

;;; Code:

(defgroup share-path '()
  "Share your current project path to external tools."
  :group 'external
  :prefix "share-path-")

(defcustom share-path-path "/tmp/emacs-share-path"
  "The file to update when the path changes.
Recommended to use a tmp file.

External programs will read the contents of the file at this path."
  :group 'share-path
  :type 'file)

(defun share-path-of-project.el ()
  (when-let ((project (project-current))) ; and a project is open
    (expand-file-name (project-root (project-current)))))

(defun share-path-of-buffer-file-name ()
  (when-let ((file-name (buffer-file-name (current-buffer))))
    (file-name-directory file-name)))

(defcustom share-path-path-functions
  '(share-path-of-project.el
    share-path-of-buffer-file-name)
  "Functions to evaluate, in order, when looking up the currect directory.
First one to return non-nil is used."
  :group 'share-path
  :type '(list function))

(defcustom share-path-update-hooks
  '(select-frame-hook
    window-buffer-change-functions
    after-delete-frame-functions)
  "List of hooks that trigger a path update."
  :group 'share-path
  :type '(list variable))

(defun share-path-update (&rest _)
  "Update the path at `share-path-path'."
  (let ((funcs share-path-path-functions)
        (path nil))
    (while (and funcs (not path))
      (setq path (funcall (pop funcs))))
    (with-temp-file share-path-path
      (insert (or path "")))))

(defun share-path--on ()
  "Called when `share-path-mode' is enabled."
  (if share-path-path
      (dolist (hook share-path-update-hooks)
        (add-hook hook #'share-path-update)
        ;; We exit the mode when Emacs exits so we can clean up our mess.
        (add-hook 'kill-emacs-hook (lambda () (share-path-mode 0))))
    (message "`share-path-path' must be set to use `share-path-mode'.")
    (share-path-mode 0)))

(defun share-path--off ()
  "Called when `share-path-mode' is disabled."
  (dolist (hook share-path-update-hooks)
    (remove-hook hook #'share-path-update))
  (delete-file share-path-path))

;;;###autoload
(define-minor-mode share-path-mode
  "Share a path with stuff."
  :group 'share-path
  :global t
  :interactive t
  (if share-path-mode
      (share-path--on)
    (share-path--off)))

(provide 'share-path)

;;; share-path.el ends here
