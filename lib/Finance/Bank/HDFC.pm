package Finance::Bank::HDFC;
use strict;
use warnings;

###########################################################################
# Copyright (C) 2005 by Rohan Almeida <rohan.almeida@gmail.com>
#
# This library is free software; you can redistribute it and/or modify
# it under the same terms as Perl itself.
###########################################################################

use version; our $VERSION = qv('0.12');

use Readonly;
use LWP::UserAgent;

# Netbanking URL
Readonly my $HDFC_URL => 'https://netbanking.hdfcbank.com/netbanking/entry';

# Transaction Codes
Readonly my %TRANSACTION_CODES => (
    login   => 'LGN',
    balance => 'SBI',
    logout  => 'LGF',
);

# HTTP timeout in seconds (default value)
Readonly my $HTTP_TIMEOUT => 20;

### CLASS METHOD ####################################################
# Usage      : $obj = Finance::Bank::HDFC->new()
# Purpose    : Creates a new F::B::H object
# Returns    : A F::B::H object
# Parameters : None
# Throws     : no exceptions
# Comments   : none
# See Also   : n/a
#######################################################################
sub new {
    my $class = shift;

    my $ua = LWP::UserAgent->new;
    $ua->timeout($HTTP_TIMEOUT);

    my $request = HTTP::Request->new( POST => $HDFC_URL );
    $request->content_type('application/x-www-form-urlencoded');

    my $self = {
        'ua'         => $ua,
        'request'    => $request,
        'session_id' => q{},
    };

    bless $self, $class;
    return $self;
}

### INSTANCE METHOD ##################################################
# Usage      :
#            : $obj->login({
#            :    cust_id => 'xxx',
#            :    password => 'xxx',
#            : });
# Purpose    : Login to the netbanking system
# Returns    : 1 on success
# Parameters : A hash ref with keys:
#            :   cust_id => HDFC customer ID
#            :   password => Netbanking PIN
# Throws     :
#            :  * "Incorrect parameters for method\n"
#            :  * "HTTP error while logging in\n"
#            :  * "Got an invalid HTTP response code: $code\n"
#            :  * "Could not get session ID\n"
# Comments   : none
# See Also   : n/a
#######################################################################
sub login {
    my ( $self, %args ) = @_;

    if ( not exists $args{'cust_id'} || not exists $args{'password'} ) {
        die "Incorrect parameters for method\n";
    }

    my $transaction_id = $TRANSACTION_CODES{'login'};

    # Build request content
    $self->{'request'}->content( "fldLoginUserId="
            . $args{'cust_id'} . '&'
            . "fldPassword="
            . $args{'password'} . '&'
            . "fldAppId=RS" . '&'
            . "fldTxnId=$transaction_id" . '&'
            . "fldScrnSeqNbr=01" . '&'
            . "fldLangId=eng&fldDeviceId=01&fldWebserverId=YG&fldAppServerId=ZZ"
    );

    my $response = $self->{'ua'}->request( $self->{'request'} );

    if ( $response->is_error ) {
        die "HTTP error while logging in\n";
    }

    if ( $response->code != 200 ) {
        die "Got invalid HTTP response code: " . $response->code . "\n";
    }

    # Get session Id
    if ( $response->content =~
        /<input value="(\w+)" name="fldSessionId" type="hidden">/ )
    {
        $self->{'session_id'} = $1;
    }
    else {
        die "Could not get session ID\n";
    }

    return 1;
}

### INSTANCE METHOD ##################################################
# Usage      : $balance = $obj->get_balance()
# Purpose    : Get balance for default account
# Returns    :
#            : 1) $balance => Account balance
# Parameters : None
# Throws     :
#            : * "Not logged in\n"
#            : * "HTTP error while getting account balance\n"
#            : * "Got an invalid HTTP response code: $code\n"
#            : * "Parse error while getting account balance\n"
# Comments   :
#            : * Does not support multiple accounts
# See Also   : n/a
#######################################################################
sub get_balance {
    my ($self) = @_;

    # Check that user has logged in
    if ( $self->{'session_id'} eq q{} ) {
        die "Not logged in\n";
    }

    # Get the account balance
    my $transaction_id = $TRANSACTION_CODES{'balance'};

    $self->{'request'}->content( "fldSessionId="
            . $self->{'session_id'} . '&'
            . "fldAppId=RS" . '&'
            . "fldTxnId=$transaction_id" . '&'
            . "fldScrnSeqNbr=01" . '&'
            . "fldModule=CH" );

    my $response = $self->{'ua'}->request( $self->{'request'} );

    if ( $response->is_error ) {
        die "HTTP error while getting account balance\n";
    }

    if ( $response->code != 200 ) {
        die "Got invalid HTTP response code: " . $response->code . "\n";
    }

    if ( $response->content =~ /balance\[count\] = "(.*)"/ ) {
        return $1;
    }
    else {
        die "Parse error while getting account balance\n";
    }
}

### INSTANCE METHOD ###################################################
# Usage      : $obj->logout()
# Purpose    : Logout from the netbanking system
# Returns    : 1 on success
# Parameters : None
# Throws     :
#            : * "Not logged in\n"
#            : * "HTTP error while logging out\n"
#            : * "Got an invalid HTTP response code: $code\n"
# Comments   : none
# See Also   : n/a
#######################################################################
sub logout {
    my ($self) = @_;

    # Check that user has logged in
    if ( $self->{'session_id'} eq q{} ) {
        die "Not logged in\n";
    }

    my $transaction_id = $TRANSACTION_CODES{'logout'};

    $self->{'request'}->content( "fldSessionId="
            . $self->{'session_id'} . '&'
            . "fldAppId=RS" . '&'
            . "fldTxnId=$transaction_id" . '&'
            . "fldScrnSeqNbr=01" . '&'
            . "fldModule=CH" );

    # Logout
    my $response = $self->{'ua'}->request( $self->{'request'} );

    if ( $response->is_error ) {
        die "HTTP error while logging out\n";
    }

    if ( $response->code != 200 ) {
        die "Got invalid HTTP response code: " . $response->code . "\n";
    }

    return 1;
}

### INSTANCE METHOD ###################################################
# Usage      : $bank->set_timeout($timeout)
# Purpose    : Set HTTP timeout for LWP::UserAgent
# Returns    : The timeout set
# Parameters :
#            :  1) $timeout => HTTP timeout in seconds
# Throws     : no exceptions
# Comments   : none
# See Also   : n/a
#######################################################################
sub set_timeout {
    my ( $self, $timeout ) = @_;

    $self->{'ua'}->timeout($timeout);
    return $self->{'ua'}->timeout();
}

1;

__END__

=head1 NAME

Finance::Bank::HDFC - Interface to the HDFC netbanking service

=head1 VERSION

This documentation refers to version 0.12

=head1 SYNOPSIS

  use Finance::Bank::HDFC;

  my $bank = Finance::Bank::HDFC->new;
  $bank->login({
    cust_id   => xxx,
    password  => xxx,
  });
  print $bank->get_balance . "\n";
  $bank->logout;
 
=head1 DESCRIPTION

This module provides an interface to the HDFC netbanking service 
at https://netbanking.hdfcbank.com/netbanking/

=head1 METHODS

=head2 new

Constructor for this class. Currently requires no arguments.

=head2 set_timeout

Sets the HTTP timeout. Parameters:

=over 4

=item * timeout => HTTP timeout in seconds

=back

Returns the timeout just set.

=head2 login

Login to the netbanking service. Requires hashref of named parameters.

=over 4

=item * cust_id - Your HDFC customer ID

=item * password - Your netbanking password (IPIN)

=back

Dies on error.

=head2 get_balance

Returns account balance. Dies on error.

=head2 logout

Logout from the netbanking service. Remember to always call this method at 
the end of your program or you may face difficulties logging in the 
next time.

Dies on error.

=head1 REQUIRES

LWP::UserAgent, Crypt::SSLeay, version, Readonly

=head1 WARNING

This warning is from Simon Cozens' Finance::Bank::LloydsTSB, and seems just as apt here.

This is code for online banking, and that means your money, and that means BE CAREFUL. 
You are encouraged, nay, expected, to audit the source of this module yourself 
to reassure yourself that I am not doing anything untoward with your banking data. 
This software is useful to me, but is provided under NO GUARANTEE, explicit or implied.

=head1 AUTHOR

Rohan Almeida E<lt>rohan.almeida@gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2005 by Rohan Almeida E<lt>rohan.almeida@gmail.comE<gt>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
