package PDL::ML::Vector::FAISS;

use strict;
use warnings;
use Exporter 'import';
use Carp qw(croak);
use XSLoader;

use PDL::Core;
use PDL::Types;
use PDL::Slices;

our $VERSION = '0.011';

our @EXPORT_OK = qw(
    flat_l2
    flat_ip
);

XSLoader::load('PDL::ML::Vector::FAISS', $VERSION);

package PDL::ML::Vector::FAISS::Index;

sub add {
    my ($self, $vectors) = @_;
    return $self->_xs_add($vectors->float());
}

sub search {
    my ($self, $queries, $k) = @_;
    $k ||= 1;
    return $self->_xs_search($queries->float(), $k);
}

1;

__END__

=encoding UTF-8

=head1 NAME

PDL::ML::Vector::FAISS - FAISS vector similarity search bindings for PDL

=head1 SYNOPSIS

    use PDL;
    use PDL::ML::Vector::FAISS qw(flat_l2 flat_ip);

    my $index = flat_l2(4);
    my $db    = float([[1,0,0,0], [0,1,0,0], [0,0,1,0]]);
    $index->add($db);

    my ($distances, $indices) = $index->search(float([[0,1,0,0]]), 2);

=head1 DESCRIPTION

C<PDL::ML::Vector::FAISS> binds L<PDL> ndarrays to Facebook AI Similarity Search (FAISS)
for fast L2 and inner-product k-NN vector search.

=head1 FUNCTIONS

=head2 flat_l2

=for ref

Create a C<PDL::ML::Vector::FAISS::Index> using exact L2 (Euclidean) distance for vectors
of dimension C<$dim>.

=for usage

    $index = flat_l2($dim);

=head2 flat_ip

=for ref

Create a C<PDL::ML::Vector::FAISS::Index> using exact inner-product similarity for vectors
of dimension C<$dim>.

=for usage

    $index = flat_ip($dim);

=head1 TUTORIAL

This tutorial translates the classic FAISS FlatL2 / FlatIP quickstart into
idiomatic Perl/PDL: creating an exact index, adding database vectors, and
running batched k-NN similarity search.

In PDL, vector batches use C<(dim, n_vectors)> layout.

    use strict;
    use warnings;
    use PDL;
    use PDL::ML::Vector::FAISS qw(flat_l2 flat_ip);

    my $dim = 4;

    # 1. Build a small database of 4 vectors in R^4
    my $db = float([
        [1.0, 0.0, 0.0, 0.0],
        [0.0, 1.0, 0.0, 0.0],
        [0.0, 0.0, 1.0, 0.0],
        [0.0, 0.0, 0.0, 1.0],
    ]);

    # 2. Exact L2 (Euclidean) index
    my $l2 = flat_l2($dim);
    $l2->add($db);
    printf "L2 index: dim=%d, ntotal=%d\n", $l2->dim, $l2->ntotal;

    my $queries = float([
        [0.0, 0.9, 0.1, 0.0],
        [0.1, 0.0, 0.0, 0.9],
    ]);
    my ($distances, $indices) = $l2->search($queries, 2);
    print "L2 nearest neighbor indices:\n$indices\n";
    print "L2 squared distances:\n$distances\n";

    # 3. Exact Inner-Product (maximum inner product / cosine on unit vectors)
    my $ip = flat_ip($dim);
    $ip->add($db);
    my ($scores, $ip_ids) = $ip->search(float([[0.0, 0.0, 2.0, 0.0]]), 2);
    printf "IP top-1 index=%d score=%.2f\n", $ip_ids->at(0, 0), $scores->at(0, 0);

See C<examples/quickstart.pl> in the distribution for a runnable version of this
tutorial.

=head1 TYPES

Supports standard real numeric PDL types (C<byte>, C<short>, C<long>, C<longlong>, C<float>, C<double> as supported by the underlying library). Complex types (C<cfloat>, C<cdouble>) are not supported by this backend.

=head1 SEE ALSO

L<PDL>, L<PDL::Torch>, L<PDL::XGBoost>, L<PDL::ONNX>, L<PDL::GGML>

=head1 AUTHOR

C.J. Collier <cjac@google.com>

=head1 COPYRIGHT AND LICENSE

Copyright 2026 Google LLC

This library is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut
