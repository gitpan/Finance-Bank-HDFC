require 5.008;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME              => 'Finance::Bank::HDFC',
    VERSION_FROM      => 'lib/Finance/Bank/HDFC.pm', # finds $VERSION
    PREREQ_PM         => { 
        'LWP::UserAgent' => 0, 
        'Crypt::SSLeay' => 0, 
        'version' => 0,
        'Readonly' => 0,
        'Test::MockModule' => 0,
        'Template::Extract' => 0,
        'URI::Escape' => 0,
    }, # e.g., Module::Name => 1.1
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM  => 'lib/Finance/Bank/HDFC.pm', # retrieve abstract from module
       AUTHOR         => 'Rohan Almeida <rohan@almeida.in>') : ()),
);
