# Mastodon With Docker

This one is *rough*, you need Mastodon(simlified here with linuxserver.io's image),
postgres, redis, and maybe a search server thing.

Ultimately transfering from pleroma still needs to be tested but may be possible:
https://git.pleroma.social/pleroma/pleroma/-/merge_requests/3524#note_97045

## Setup for portainer
I've extensively used substitution variables in this compose script to be replaced
with the credentials file. You will need to modify it to suite your setup.

## Elasticsearch vs. Manticore

Elasticsearch seems to refuse to run under Docker rootless and I've attempted
to replace it with Manticore. I have no idea if it is working or not, there
are no errors in the mastodon logs at the least

## Need email.

Look into using MailHog as a temporary email provider to authenticate the creation
of a user. This will probably be needed to test search.
