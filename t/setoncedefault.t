use strict;
use warnings;
use Test::More;
use Test::Fatal;
use Test::Moose;

use lib 'lib';
require MooseX::SetOnce;

{
  package Apple;
  use Moose;

  has color => (
    is     => 'rw',
    traits => [ qw(SetOnce) ],
    default=>'Puce'
  );
}



with_immutable {
for my $set (
  [ Apple     => qw(    color     color) ],
) {
  my ($class, $getter, $setter) = @$set;
  my $object = $class->new;

  {
    is($object->$getter, 'Puce', "it has the default value we set");

    is(
      exception { $object->$setter('green'); },
      undef,
      "can set a SetOnce attr once",
    );

    is($object->$getter, 'green', "it has the first value we set");
  }

  {
    like(
      exception { $object->$setter('blue'); },
      qr{cannot change value.+\bcolor\b},
      "can't set a SetOnce attr twice (via $setter)",
    );
    is($object->$getter, 'green', "it has the first value we set");
  }

  {
    like(
      exception {
        $object->meta->find_attribute_by_name('color')->set_value($object, 'yellow');
      },
      qr{cannot change value.+\bcolor\b},
      "can't set a SetOnce attr twice (via set_value)",
    );
    is($object->$getter, 'green', "it has the first value we set");
  }

  my $object2 = $class->new(color => 'green');

  {
    like(
      exception { $object2->$setter('blue'); },
      qr{cannot change value.+\bcolor\b},
      "can't set a SetOnce attr twice (via $setter)",
    );
    is($object2->$getter, 'green', "it has the first value we set");
  }

  {
    like(
      exception {
        $object2->meta->find_attribute_by_name('color')->set_value($object, 'yellow');
      },
      qr{cannot change value.+\bcolor\b},
      "can't set a SetOnce attr twice (via set_value)",
    );
    is($object2->$getter, 'green', "it has the first value we set");
  }
}
} 'Apple';

done_testing;
