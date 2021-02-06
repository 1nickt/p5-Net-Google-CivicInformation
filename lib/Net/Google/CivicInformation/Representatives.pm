package Net::Google::CivicInformation::Representatives;

our $VERSION = '0.02';

use strict;
use warnings;
use v5.10;

use Carp 'croak';
use Function::Parameters;
use JSON::MaybeXS;
use Types::Common::String 'NonEmptyStr';
use Moo;
use namespace::clean;

extends 'Net::Google::CivicInformation';

##
sub _build__api_url {
    return 'representatives';
}

##
method representatives_for_address (NonEmptyStr $address) {
    my $uri = URI->new( $self->_api_url );
    $uri->query_form(
        address => $address,
        key => $self->api_key,
    );

    my $call = $self->_client->get( $uri );

    if ( ! $call->{success} ) {
        croak 'Call to Google failed : response as follows - ' . $call->{content};
    }
    else {
        my $data = decode_json( $call->{content} );

        my @result;

        my @officials = @{ $data->{officials} };

        for my $job ( @{ $data->{offices} } ) {

            for my $person ( @officials[ @{ $job->{officialIndices} } ] ) {
                push( @result, {
                    title         => $job->{name},
                    name          => $person->{name},
                    party         => $person->{party},
                    addresses     => $person->{address},
                    phone_numbers => $person->{phones},
                    emails        => $person->{emails},
                    websites      => $person->{urls},
                    social_media  => $person->{channels},
                });

            }
        }

        return \@result;
    }
}

1; # return true

=pod

=encoding utf8

=head1 NAME

Net::Google::CivicInformation::Representatives - All elected representatives for US addresses

=head1 SYNOPSIS

  my $client = Net::Google::CivicInformation::Representatives->new( api_key => '***' );

  my $res = $client->representatives_for_address('123 Main St Springfield MO 12345');

  if ( $res->error ) {
      # handle the error returned (JSON obj, see below)
  }
  else {
      # MORE DOC NEEDED HERE
  }

=head1 METHODS

=over

=item B<representatives_for_address>

Requires an address string as the only argument. Returns an object providing methods
to access the reponse data, or else a method C<error> containing MORE DOC NEEDED HERE.

=cut