# genservers-elixir-meetup-march-19-2018

## Pre-requisites

Create the following aliases:

Alias to go to the next slide:

    git config --global alias.next '!git checkout `git rev-list HEAD..demo-end | tail -1`'

To go to the previous slide:

    git config --global alias.prev 'checkout HEAD^'

## Presenting

To start presentation do:

    git checkout demo-start

To go to next slide do:

    git next

To go to previous slide do:

    git prev

To restore vim folds, issue from within vim:

    :source folds.v

Disable spell-checking (so that there are no red underlines):

    :set nospell

## References

Based on the idea of using git for a live coding sessions:
https://blog.jayway.com/2015/03/30/using-git-commits-to-drive-a-live-coding-session/

Prepared by utilizing interactive rebases:
https://www.atlassian.com/git/tutorials/rewriting-history#git-rebase-i

Blatantly copied code and translated from Erlang to Elixir from
"Learn You Some Erlang" by Fred Hebert. Specifically used chapters:

- http://learnyousomeerlang.com/the-hitchhikers-guide-to-concurrency
- http://learnyousomeerlang.com/more-on-multiprocessing
- http://learnyousomeerlang.com/errors-and-processes
- http://learnyousomeerlang.com/what-is-otp
