use 5.010;
use strict;
use warnings;
use ExtUtils::MakeMaker;
use ExtUtils::CppGuess;
use PDL::Core::Dev;

my $brew_prefix = '';
if ($^O eq 'darwin') {
    chomp($brew_prefix = `brew --prefix 2>/dev/null` || '');
}
my @inc_dirs = ('/usr/include', '/usr/local/include');
push @inc_dirs, "$brew_prefix/include" if $brew_prefix;
my $faiss_inc;
for my $dir (@inc_dirs) {
    if (-f "$dir/faiss/IndexFlat.h") {
        $faiss_inc = $dir;
        last;
    }
}
if (!$faiss_inc) {
    die "libfaiss-dev (faiss/IndexFlat.h) is required to build PDL::ML::Vector::FAISS.\n";
}
my $lib_flag = ($brew_prefix && $faiss_inc && $faiss_inc =~ m{^\$brew_prefix}) ? "-L$brew_prefix/lib " : '';

my $pdl_inc      = PDL::Core::Dev::PDL_INCLUDE();
my $guess        = ExtUtils::CppGuess->new();
my %cpp_opts     = $guess->makemaker_options();
my $cpp_compiler = $guess->compiler_command() || 'g++';
my $cpp_libs     = $guess->linker_flags()     || '-lstdc++';
my $cpp_flags    = ($cpp_opts{CCFLAGS} || '') . ' -std=c++17';

WriteMakefile(
    NAME               => 'PDL::ML::Vector::FAISS',
    AUTHOR             => q{C.J. Collier <cjac@google.com>},
    VERSION_FROM       => 'lib/PDL/ML/Vector/FAISS.pm',
    ABSTRACT_FROM      => 'lib/PDL/ML/Vector/FAISS.pm',
    LICENSE            => 'perl_5',
    MIN_PERL_VERSION   => '5.010',
    CONFIGURE_REQUIRES => {
        'ExtUtils::MakeMaker' => '0',
        'ExtUtils::CppGuess'  => '0.26',
        'PDL'                 => '2.080',
    },
    TEST_REQUIRES => {
        'Test::More' => '0.88',
    },
    PREREQ_PM => {
        'PDL' => '2.080',
    },
    INC    => '-I. ' . $pdl_inc . ' -I' . $faiss_inc,
    LIBS   => [ $lib_flag . '-lfaiss -lgomp -lblas -llapack ' . $cpp_libs ],
    ($brew_prefix ? (dynamic_lib => { OTHERLDFLAGS => "-L$brew_prefix/lib -Wl,-rpath,$brew_prefix/lib -lfaiss -framework Accelerate" }) : ()),
    OBJECT => 'FAISS$(OBJ_EXT) faiss_bridge$(OBJ_EXT)',
    XS     => { 'FAISS.xs' => 'FAISS.c' },
    clean  => { FILES => 'PDL-ML-Vector-FAISS-* *.o FAISS.bs FAISS.c' },
    META_MERGE => {
        'meta-spec' => { version => 2 },
        resources   => {
            repository => {
                type => 'git',
                url  => 'https://github.com/PDLPorters/PDL-ML-Vector-FAISS.git',
                web  => 'https://github.com/PDLPorters/PDL-ML-Vector-FAISS',
            },
            bugtracker => {
                web => 'https://github.com/PDLPorters/PDL-ML-Vector-FAISS/issues',
            },
        },
    },
);

package MY;

sub postamble {
    return <<"END_MAKE";
CXX = $cpp_compiler
CXXFLAGS = $cpp_flags -O2 -fPIC

faiss_bridge\$(OBJ_EXT): faiss_bridge.cc faiss_bridge.h
\t\$(CXX) \$(CXXFLAGS) -I. -I$faiss_inc -c faiss_bridge.cc -o faiss_bridge\$(OBJ_EXT)
END_MAKE
}
