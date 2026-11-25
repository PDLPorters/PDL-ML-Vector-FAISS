# PDL::ML::Vector::FAISS

Facebook AI Similarity Search (FAISS) C++/XS bindings for [PDL](https://pdl.perl.org/), providing fast exact L2 (`flat_l2`) and inner-product (`flat_ip`) k-NN vector search over PDL ndarrays.

## Prerequisites

Install FAISS development libraries and headers (e.g. `libfaiss-dev` or a local FAISS build).

## Installation

```bash
cpanm .
```

Or via ExtUtils::MakeMaker:

```bash
perl Makefile.PL
make
make test
make install
```

## Quickstart

```perl
use strict;
use warnings;
use PDL;
use PDL::ML::Vector::FAISS qw(flat_l2 flat_ip);

my $db = float([
    [1.0, 0.0, 0.0, 0.0],
    [0.0, 1.0, 0.0, 0.0],
    [0.0, 0.0, 1.0, 0.0],
    [0.0, 0.0, 0.0, 1.0],
]);

my $index = flat_l2(4);
$index->add($db);

my ($distances, $indices) = $index->search(float([[0.0, 0.9, 0.1, 0.0]]), 2);
printf "Top-1 index=%d distance=%.4f\n", $indices->at(0, 0), $distances->at(0, 0);
```

## Documentation & Examples

- Runnable tutorial: `perl examples/quickstart.pl` (see [`examples/quickstart.pl`](examples/quickstart.pl))
- Full POD documentation: `perldoc PDL::ML::Vector::FAISS` (or [`lib/PDL/ML/Vector/FAISS.pm`](lib/PDL/ML/Vector/FAISS.pm))

## License

Copyright 2026 Google LLC. Licensed under the the same terms as Perl itself.
