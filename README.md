## Overview

`helm-org-files` would list all org files in the helm buffer, including:

* Currently opened org files
* Bookmarked org files

## Installation

- install `helm` from github
- clone the `helm-org-files` repository to "~/.emacs.d/helm-org-files"
- add to your config

```elisp
     (push "~/.emacs.d/helm-org-files" load-path)
     (require 'helm-config)
     (require 'helm-org-files)
     (global-set-key (kbd "M-o") 'helm-org-files)
```

## Usage

`M-x helm-org-files` and there you go.

## Motivation

Most of my personal notes are kept in org-mode files, and during my daily work I
switch frequently between my org files and other source code files.

The `org-switchb` function provided by org-mode is good enough, but it can
only switch to currently opened org buffers, while many times I found I want
to visit a bookmarked but not yet opened org file. So I wrote this simple
package to do this.
