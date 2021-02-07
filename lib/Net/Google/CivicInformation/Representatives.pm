package Net::Google::CivicInformation::Representatives;

our $VERSION = '1.02';

use strict;
use warnings;
use v5.10;

use Carp 'croak';
use Function::Parameters;
use JSON::MaybeXS;
use Try::Tiny;
use Types::Common::String 'NonEmptyStr';
use URI;
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
        key     => $self->api_key,
    );

    my $call = $self->_client->get( $uri );
    my $response;

    try {
        if ( ! $call->{success} ) {
            my $resp = decode_json( $call->{content} );
            $response = $resp;
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

            $response = { officials => \@result };
        }
    }
    catch {
        $response = {
            error => {
                message => 'Caught fatal error trying to call Google API',
            },
        };
    };

    return $response;
}

1; # return true

=pod

=encoding utf8

=head1 NAME

Net::Google::CivicInformation::Representatives - All elected representatives for US addresses

=head1 SYNOPSIS

  my $client = Net::Google::CivicInformation::Representatives->new( api_key => '***' );

  my $res = $client->representatives_for_address('123 Main St Springfield MO 12345');

  if ( $res->{error} ) {
      # handle the error hash returned
  }
  else {
      for my $official ( $res->{officals} ) {
          # use the data hash
      }
  }

=head1 METHODS

=over

=item B<representatives_for_address (NonEmptyStr $address)>

Requires an address string as the only argument.

On error, the response will contain a key C<error> containing a hashref like:

  {
    'error' => {
      'code' => 400,
      'errors' => [
        {
          'domain' => 'global',
          'message' => 'Failed to parse address',
          'reason' => 'parseError'
        }
      ],
      'message' => 'Failed to parse address'
    }
  }

On success, the response will contain an key C<officials> containing an arrayref of
hashrefs, ordered by descending seniority (head of state down). Each hashref
represents a single official: there may be more than one record at the same "rank."
The hashref will contain the following keys:

=over

=item name (string)

=item title (string)

=item party (string)

=item addresses (arrayref of hashrefs)

=item phone_numbers (arrayref of strings)

=item websites (arrayref of strings)

=item social_media (arrayref of hashrefs)

=back

=back

=cut