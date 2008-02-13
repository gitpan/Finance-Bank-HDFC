#!/usr/bin/perl
use strict; use warnings;
$|++;

use Finance::Bank::HDFC;

# Fill in your HDFC customer ID and password
my $cust_id = 'xxxxxxxx';
my $password = 'xxxxxxxx';

my $bank = Finance::Bank::HDFC->new;
$bank->login(
	cust_id		=> $cust_id,
	password	=> $password,
);
print "Balance: " . $bank->get_balance . "\n";
$bank->logout;

