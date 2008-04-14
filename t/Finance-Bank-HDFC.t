#!/usr/bin/perl
use strict; use warnings;

use lib 'lib';

use Test::More tests => 12;
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
$get_balance_data .= <DATA>;
my $mini_statement_data;
{
    undef $/;
    $mini_statement_data = <DATA>;
}

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

# test for get_mini_statement()
{
    my $lwp = Test::MockModule->new( 'LWP::UserAgent' );
    $lwp->mock( request => sub { 
        # Lets return a hand crafted HTTP::Response object
        my $response = HTTP::Response->new;
        $response->code(200);
        $response->content($mini_statement_data);
        return $response;
    });

    # Test the get_mini_statement method
    my @statements = $bank->get_mini_statement();
    ok (scalar @statements == 2, 'get_mini_statement');
    ok ($statements[0]->{amount} eq '0.01', 'get_mini_statement');
    ok ($statements[0]->{balance} eq '999999.99', 'get_mini_statement');
    ok ($statements[1]->{amount} eq '1000000.00', 'get_mini_statement');
    ok ($statements[1]->{balance} eq '1000000.00', 'get_mini_statement');
    ok ($statements[1]->{type} eq 'C', 'get_mini_statement');

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
accounts[count] = "08331205003692  ";
balance[count] = "999999.99";

	dattxn[l_count] = '10 Apr 2008';
	txndesc[l_count] = "Description blah blah";
	refchqnbr[l_count] = '000003009168';
	datvalue[l_count] = '11 Apr 2008';
	amttxn[l_count] = '0.01';
	balaftertxn[l_count] = '999999.99';
	coddrcr[l_count] = 'D';
	l_count ++;

	dattxn[l_count] = '01 Apr 2008';
	txndesc[l_count] = "Fooled you! Damn millionaire?";
	refchqnbr[l_count] = '037103902179';
	datvalue[l_count] = '01 Apr 2008';
	amttxn[l_count] = '1000000.00';
	balaftertxn[l_count] = '1000000.00';
	coddrcr[l_count] = 'C';
	l_count ++;

