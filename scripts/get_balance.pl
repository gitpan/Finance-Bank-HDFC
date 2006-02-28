#!/usr/bin/perl
use strict; use warnings;
$|++;

#use lib 'lib';
use Finance::Bank::HDFC;

my $cust_id = 'XXXXXXX';
my $password = 'XXXX';

my $bank = Finance::Bank::HDFC->new;
$bank->login(
	cust_id		=> $cust_id,
	password	=> $password,
);
print "Balance: " . $bank->get_balance . "\n";
$bank->logout;

