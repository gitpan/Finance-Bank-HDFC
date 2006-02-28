#!/usr/bin/perl
use strict; use warnings;

use lib 'lib';

use Test::More tests => 6;
use Test::MockModule;

my $module = 'Finance::Bank::HDFC';

use_ok($module) or die;

my $bank = Finance::Bank::HDFC->new;
isa_ok($bank, $module);

# set_timeout
my $timeout = $bank->set_timeout(10);
ok($timeout == 10, 'set_timeout');

# Lets get data for the tests
my $login_data = <DATA>;
my $get_balance_data = <DATA>;

# Test the login method
# Lets mock the LWP::UserAgent's request method
{
    my $lwp = Test::MockModule->new( 'LWP::UserAgent' );
    $lwp->mock( request => sub { 
        # Lets return a hand crafted HTTP::Response object
        my $response = HTTP::Response->new;
        $response->code(200);
        $response->content($login_data);
        return $response;
    });

    # Test the login method
    my $ret = $bank->login(
                cust_id     => 'XXX',
                password    => 'XXX',
    );
    is($ret, 1, "login");
}

# Test the get_balance method

# Lets mock the LWP::UserAgent's request method
# XXX: Need to change this code, as we need to mock LWP::UserAgent for every
# call. Maybe we need to use Test::MockObject ?

{
    my $lwp = Test::MockModule->new( 'LWP::UserAgent' );
    $lwp->mock( request => sub { 
        # Lets return a hand crafted HTTP::Response object
        my $response = HTTP::Response->new;
        $response->code(200);
        $response->content($get_balance_data);
        return $response;
    });

    # Test the get_balance method
    my $amt = $bank->get_balance();
    is($amt, "999999.99", "get_balance");
}

# Test the logout method
{
    my $lwp = Test::MockModule->new( 'LWP::UserAgent' );
    $lwp->mock( request => sub { 
        # Lets return a hand crafted HTTP::Response object
        my $response = HTTP::Response->new;
        $response->code(200);
        return $response;
    });

    # Test the logout method
    my $ret = $bank->logout();
    is($ret, 1, 'logout');
}
__DATA__
<input value="RS" name="fldAppId" type="hidden"><input value="MNU" name="fldTxnId" type="hidden"><input value="09" name="fldScrnSeqNbr" type="hidden"><input value="405819949ICZJFCXJT" name="fldSessionId" type="hidden"><input value="" name="customername" type="hidden"></form>
balance[count] = "999999.99";
