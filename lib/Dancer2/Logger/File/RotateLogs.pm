package Dancer2::Logger::File::RotateLogs;
# ABSTRACT: file-based rotate logging engine for Dancer2
$Dancer2::Logger::File::RotateLogs::VERSION = '0.01';
use Carp 'carp';
use Moo;
use File::Spec;
use File::RotateLogs;
use Dancer2::Core::Types;
use Data::Dumper;

with 'Dancer2::Core::Role::Logger'; 

my $ROTATELOGS;

has environment => (
    is       => 'ro',
    required => 1,
);

has location => (
    is       => 'ro',
    required => 1,
);

has log_dir => (
    is      => 'rw',
    isa     => sub {
        my $dir = shift;
        
        if ( !-d $dir && !mkdir $dir ) {
            die "log directory \"$dir\" does not exist and unable to create it.";
        }
        if ( !-w $dir ) {
            die "log directory \"$dir\" is not writable."
        }
    },
    lazy    => 1,
    builder => '_build_log_dir',
);

has logfile => (
    is       => 'ro',
    required => 1,
    lazy => 1,
    default  => sub {
        my $self = shift;
        File::Spec->catfile(File::Spec->rel2abs($self->log_dir), $self->environment.'.log').".%Y%m%d%H";
    },
);

has linkname => (
    is       => 'ro',
    required => 1,
    lazy => 1,
    default  => sub {
        my $self = shift;
        File::Spec->catfile(File::Spec->rel2abs($self->log_dir), $self->environment.'.log');
    },
);

has rotationtime => (
    is       => 'ro',
    required => 1,
);

has maxage => (
    is       => 'ro',
    required => 1,
    coerce => sub { 
        $_[0] =~ /^\d+$/ ? $_[0] : int eval($_[0])
    },
);

sub BUILD {
    my ($self) = @_;
    #print Dumper($self->logfile);
    #print Dumper($self->linkname);
    #print Dumper($self->rotationtime);
    #print Dumper($self->maxage);
    $ROTATELOGS = File::RotateLogs->new({
        logfile      => $self->logfile,
        linkname     => $self->linkname,
        rotationtime => $self->rotationtime,
        maxage       => $self->maxage,
    });
}

sub _build_log_dir {
    File::Spec->catdir( $_[0]->location, 'logs' );
}

sub log {
    my ( $self, $level, $message ) = @_; 
    $ROTATELOGS->print($self->format_message( $level => $message ));
}

1;
__END__

=encoding utf-8

=head1 NAME

Dancer2::Logger::File::RotateLogs - It's new $module

=head1 SYNOPSIS

    use Dancer2::Logger::File::RotateLogs;

=head1 DESCRIPTION

Dancer2::Logger::File::RotateLogs is ...

=head1 LICENSE

Copyright (C) Masaaki Saito.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Masaaki Saito E<lt>masakyst.mobile@gmail.comE<gt>

=cut

