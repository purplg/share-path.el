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

(defcustom share-path-path-function
  (lambda ()
    (when-let ((project (project-current))) ; and a project is open
      (expand-file-name (project-root (project-current)))))
  "Function called when looking up the currect directory."
  :group 'share-path
  :type 'function)

(defcustom share-path-update-hooks
  '(select-frame-hook
    window-buffer-change-functions
    after-delete-frame-functions)
  "List of hooks that trigger a path update."
  :group 'share-path
  :type '(list variable))

(defun share-mode-update (&rest _)
  "Update the path at `share-path-path'."
  (with-temp-file share-path-path
    (when-let ((path (funcall share-path-path-function)))
      (insert path))))

(defun share-path--mode-enable ()
  "Called when `share-path-mode' is enabled."
  (if share-path-path
      (dolist (hook share-path-update-hooks)
        (add-hook hook #'share-mode-update)
        ;; We exit the mode when Emacs exits so we can clean up our mess.
        (add-hook 'kill-emacs-hook (lambda () (share-path-mode 0))))
    (message "`share-path-path' must be set to use `share-path-mode'.")
    (share-path-mode 0)))

(defun share-path--mode-disable ()
  "Called when `share-path-mode' is disabled."
  (dolist (hook share-path-update-hooks)
    (remove-hook hook #'share-mode-update))
  (delete-file share-path-path))

;;;###autoload
(define-minor-mode share-path-mode
  "Share a path with stuff."
  :group 'share-path
  :global t
  :interactive t
  (if share-path-mode
      (share-path--mode-enable)
    (share-path--mode-disable)))

(provide 'share-path)

;;; share-path.el ends here
