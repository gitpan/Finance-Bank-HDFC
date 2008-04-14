#!/usr/bin/perl
use strict; use warnings;
$|++;

use Finance::Bank::HDFC;
use Data::Dumper;

# HDFC Netbanking login details
my $cust_id = 'xxx';
my $password = 'xxx';

my $bank = Finance::Bank::HDFC->new;
$bank->login(
	cust_id		=> $cust_id,
	password	=> $password,
);
my @statements = $bank->get_mini_statement();
$bank->logout;

print Dumper \@statements;

