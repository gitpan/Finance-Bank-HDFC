package Finance::Bank::HDFC;
use strict; use warnings;


###########################################################################
# Copyright (C) 2005 by Rohan Almeida
#
# This library is free software; you can redistribute it and/or modify
# it under the same terms as Perl itself.
###########################################################################

our $VERSION = "0.0.3";

use LWP::UserAgent;

# Netbanking URL
my $HDFC_URL = 'https://netbanking.hdfcbank.com/netbanking/entry';

# Transaction Codes
my %TRANSACTION_CODES = (
                login   => 'LGN',
                balance => 'SBI',
                logout  => 'LGF',
);

# HTTP timeout
my $HTTP_TIMEOUT = 10;

sub new
{
    my $class = shift;

    my $ua = LWP::UserAgent->new;
    $ua->timeout($HTTP_TIMEOUT);

    my $request = HTTP::Request->new(POST => $HDFC_URL);
    $request->content_type('application/x-www-form-urlencoded');

    my $self = {
        'ua'            => $ua,
        'request'       => $request,
    };

    bless $self, $class;
    return $self;
}


sub login
{
    my $self = shift;
    my %args = @_;

    if (not exists $args{'cust_id'} || not exists $args{'password'}) {
        return -1;
    }

    my $transaction_id = $TRANSACTION_CODES{'login'};

    $self->{'request'}->content(
            "fldLoginUserId=" . $args{'cust_id'} . '&' . 
            "fldPassword=" . $args{'password'} . '&' . 
            "fldAppId=RS" . '&' . 
            "fldTxnId=$transaction_id" . '&' . 
            "fldScrnSeqNbr=01" . '&' . 
            "fldLangId=eng&fldDeviceId=01&fldWebserverId=YG&fldAppServerId=ZZ"
    );

    my $response = $self->{'ua'}->request($self->{'request'});

    if ($response->code != 200) {
        return -1;
    }

    # Get session Id
    if ($response->content 
            =~ /<input value="(\w+)" name="fldSessionId" type="hidden">/) 
    {
        $self->{'session_id'} = $1;
    }
    else {
        return -1;
    }
    
    return 1;
}

sub get_balance
{
    my $self = shift;

    # Get the account balance
    my $transaction_id = $TRANSACTION_CODES{'balance'};

    $self->{'request'}->content(
            "fldSessionId=" . $self->{'session_id'} . '&' . 
            "fldAppId=RS" . '&' . 
            "fldTxnId=$transaction_id" . '&' . 
            "fldScrnSeqNbr=01" . '&' . 
            "fldModule=CH"
    );
    
    my $response = $self->{'ua'}->request($self->{'request'});
    if ($response->code != 200) {
        return -1;
    }
    
    if ($response->content =~ /balance\[count\] = "(.*)"/) {
        return $1;
    }
    else {
        return -1;
    }
}


sub logout
{
    my $self = shift;

    my $transaction_id = $TRANSACTION_CODES{'logout'};

    $self->{'request'}->content(
            "fldSessionId=" . $self->{'session_id'} . '&' . 
            "fldAppId=RS" . '&' . 
            "fldTxnId=$transaction_id" . '&' . 
            "fldScrnSeqNbr=01" . '&' . 
            "fldModule=CH"
    );

    # Logout
    my $response = $self->{'ua'}->request($self->{'request'});

    if ($response->code != 200) {
        return -1;
    }
    
    return 1;
}

1;

__END__

=head1 NAME

Finance::Bank::HDFC - Interface to the HDFC netbanking service

=head1 SYNOPSIS

  use Finance::Bank::HDFC;

  my $bank = Finance::Bank::HDFC->new;
  $bank->login(
    cust_id   => xxx,
    password  => xxx,
  );
  print $bank->get_balance . "\n";
  $bank->logout;
 
=head1 DESCRIPTION

This module provides an interface to the HDFC netbanking service 
at https://netbanking.hdfcbank.com/netbanking/

=head1 METHODS

=head2 new

Constructor for this class. Currently requires no arguments.

=head2 login

Login to the netbanking service. Requires following named parameters.

=over 4

=item * cust_id - Your HDFC customer ID

=item * password - Your netbanking password

=back

Returns 1 on success, -1 on failure.

=head2 get_balance

Retrieves your account balance. Returns -1 on failure.

=head2 logout

Logout from the netbanking service. Remember to always call this method at 
the end of your program or you may face difficulties logging in the 
next time.

Returns 1 on success, -1 on failure.

=head1 REQUIRES

LWP::UserAgent, Crypt::SSLeay

=head1 WARNING

This warning is from Simon Cozens' Finance::Bank::LloydsTSB, and seems just as apt here.

This is code for online banking, and that means your money, and that means BE CAREFUL. 
You are encouraged, nay, expected, to audit the source of this module yourself 
to reassure yourself that I am not doing anything untoward with your banking data. 
This software is useful to me, but is provided under NO GUARANTEE, explicit or implied.

=head1 AUTHOR

Rohan Almeida, E<lt>arcofdescent@gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2005 by Rohan Almeida

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
