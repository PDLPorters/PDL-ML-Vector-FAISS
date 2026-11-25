# Copyright 2026 Google LLC
use strict;
use warnings;
use PDL;
use PDL::ML::Vector::FAISS qw(flat_l2 flat_ip);

my $dim = 4;

# 1. Build a database of 4 vectors in R^4 (shape: dim x n_vectors)
my $db = float([
    [1.0, 0.0, 0.0, 0.0],
    [0.0, 1.0, 0.0, 0.0],
    [0.0, 0.0, 1.0, 0.0],
    [0.0, 0.0, 0.0, 1.0],
]);

# 2. Exact L2 (Euclidean) k-NN search
my $l2 = flat_l2($dim);
$l2->add($db);
printf "L2 index: dim=%d, ntotal=%d\n", $l2->dim, $l2->ntotal;

my $queries = float([
    [0.0, 0.9, 0.1, 0.0],
    [0.1, 0.0, 0.0, 0.9],
]);
my ($distances, $indices) = $l2->search($queries, 2);
print 'L2 nearest neighbor indices:', "\n", $indices, "\n";
print 'L2 squared distances:', "\n", $distances, "\n";

# 3. Exact Inner-Product search
my $ip = flat_ip($dim);
$ip->add($db);
my ($scores, $ip_ids) = $ip->search(float([[0.0, 0.0, 2.0, 0.0]]), 2);
printf "IP top-1 index=%d score=%.2f\n", $ip_ids->at(0, 0), $scores->at(0, 0);
