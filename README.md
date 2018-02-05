# bbs-check-status (1.0)
Checks the status of the BBSs in the JV-LD component
Official support sites: [Official Github Repo](https://github.com/fstltna/bbs-check-status), or mail to marisag@bbslist.synchronetbbs.org

***

1. Copy **config.ini.example** to **config.ini** and edit it for your settings. If you don't know what your table prefix is you can use the following commands to see what it is. The prefix MUST end with a "_".
        **mysql -p
        use joomla;
        show tables;
        quit;**
        The prefix is what appears at the start of every field in that list.
2. Use CPAN to install the following Perl modules:
        **IO::Socket::PortState
        DBI**
3. Create the following extra fields in the JV-LD backend configuration as described in the file **JV-LD_ExtraFields.txt**
4. Create a cron job to run several times per day like this:
        **1 \*/6 * * * /root/bbs-check-status/scan-bbs-list.pl**
5. That should be enough, it should be workable now.
