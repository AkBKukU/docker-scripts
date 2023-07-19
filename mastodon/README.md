# Mastodon With Docker

This one is *rough*, you need Mastodon(simlified here with linuxserver.io's image),
postgres, redis, and maybe a search server thing.

Ultimately transfering from pleroma still needs to be tested but may be possible:
https://git.pleroma.social/pleroma/pleroma/-/merge_requests/3524#note_97045

## Setup With Portainer

I've extensively used substitution variables in this compose script to be
replaced with the credentials file. You will need to modify `credentials.env`
to suite your setup.

Per the [linuxserver/docker-mastodon](https://github.com/linuxserver/docker-mastodon)
docs you will also need to run:

    docker run --rm -it --entrypoint /bin/bash lscr.io/linuxserver/mastodon generate-secret

to generate a key value for both `SECRET_KEY_BASE` & `OTP_SECRET`. And this

    docker run --rm -it --entrypoint /bin/bash lscr.io/linuxserver/mastodon generate-vapid

for `VAPID_PRIVATE_KEY` & `VAPID_PUBLIC_KEY` all of which you can set in the
credentials file before loading it.

It should run after that.

Once it's started, create an account for the admin (see [Email](#Email) for
auth). Per the [Mastodon Docs](https://docs.joinmastodon.org/admin/setup/#admin)
You will need to log into the console and run the following command:

    RAILS_ENV=production bin/tootctl accounts modify $ACCOUNT_NAME --role Owner

This will mark that account as owner and allow access to the management tools.


## Elasticsearch, Manticore, and failing

Elasticsearch seems to refuse to run under Docker rootless and I've attempted
to replace it with Manticore. Elasticsearch needs to have ulimits raised to
work which I haven't been able to do. The following did not work:
 - https://github.com/moby/moby/issues/40942
 - https://unix.stackexchange.com/questions/366352/etc-security-limits-conf-not-applied

Manticore never seemed to work either for reasons I couldn't diagnoes. I saw
requests from the mastodon container but it was throwing MySQL errors for some
reason. It may need setup, or it may not even be compatible. I have no idea.

I would like to get Eleaticsearch working but I would also like to be done, so
I'm giving up.

## Email

Mastodon needs email to authenticate users, annoyingly. Setting up email
is a nightmare and my intentions do not require it.

To work around it temporarilly download a standalone copy of
[MailHog]https://github.com/mailhog/MailHog/releases) and run it on the host
machine. Set the SMTP port in Mastodon to the host IP and SMTP user and pass
to anything. MailHog will show the email that would have been sent in a web page.
Use that to validate the account and then never worry about it again.
