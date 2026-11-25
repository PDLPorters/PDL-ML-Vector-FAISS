use strict;
use warnings;
use Test::More;
use PDL;
use PDL::ML::Vector::FAISS qw(flat_l2);

subtest 'WoLF PSORT-style k-NN protein localization tutorial' => sub {
    # Reference feature vectors (4-D): 3 cytoplasmic (class 0), 3 nuclear (class 1)
    my $ref = pdl(float, [
        [0.10, 0.15, 0.20, 0.10],
        [0.12, 0.18, 0.19, 0.11],
        [0.09, 0.14, 0.22, 0.08],
        [0.85, 0.90, 0.80, 0.88],
        [0.82, 0.87, 0.84, 0.91],
        [0.88, 0.92, 0.79, 0.86],
    ]);
    my @labels = (0, 0, 0, 1, 1, 1);

    my $idx = flat_l2(4);
    $idx->add($ref);

    my $query = pdl(float, [
        [0.11, 0.16, 0.21, 0.09],
        [0.86, 0.89, 0.81, 0.89],
    ]);
    my ($dists, $ids) = $idx->search($query, 3);

    my @q0_votes = map { $labels[ $ids->at($_, 0) ] } (0 .. 2);
    my @q1_votes = map { $labels[ $ids->at($_, 1) ] } (0 .. 2);
    is_deeply(\@q0_votes, [0, 0, 0], 'cytoplasmic query retrieves 3 cytoplasmic neighbors');
    is_deeply(\@q1_votes, [1, 1, 1], 'nuclear query retrieves 3 nuclear neighbors');
    ok($dists->at(0, 0) < 0.01, 'nearest neighbor L2 distance is small');
};

subtest 'disconfirmation: dimension mismatch throws error' => sub {
    my $idx = flat_l2(4);
    my $bad = pdl(float, [[1.0, 2.0, 3.0]]);
    my $ok = eval { $idx->add($bad); 1 };
    ok(!$ok, 'adding 3-D vector to 4-D index dies');
};

done_testing();
