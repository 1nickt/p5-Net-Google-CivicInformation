use strict; use warnings;
use Test::Most 'die';

use_ok 'Net::Google::CivicInformation' or BAIL_OUT 'Cannot load Net::Google::CivicInformation!';
use_ok 'Net::Google::CivicInformation::Representatives' or BAIL_OUT 'Cannot load Net::Google::CivicInformation::Representatives!';

done_testing;