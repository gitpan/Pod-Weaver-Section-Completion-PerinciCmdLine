package Pod::Weaver::Section::Completion::PerinciCmdLine;

our $DATE = '2014-11-23'; # DATE
our $VERSION = '0.05'; # VERSION

use 5.010001;
use Moose;
with 'Pod::Weaver::Role::Section';

use List::Util qw(first);
use Moose::Autobox;

sub weave_section {
    my ($self, $document, $input) = @_;

    my $filename = $input->{filename} || 'file';

    my $command_name;
    if ($filename =~ m!^(bin|script)/(.+)$!) {
        $command_name = $2;
    } else {
        $self->log_debug(["skipped file %s (not an executable)", $filename]);
        return;
    }

    # find file content in zilla object, not directly in filesystem, because the
    # file might be generated dynamically by dzil.
    my $file = first { $_->name eq $filename } @{ $input->{zilla}->files };
    unless ($file) {
        $self->log_fatal(["can't find file %s in zilla object", $filename]);
    }
    my $content = $file->content;
    #unless ($content =~ /\A#!.+perl/) {
    #    $self->log_debug(["skipped file %s (not a Perl script)",
    #                      $filename]);
    #    return;
    #}
    unless ($content =~ /(use|require)\s+Perinci::CmdLine(::Any|::Lite)?/) {
        $self->log_debug(["skipped file %s (does not use Perinci::CmdLine)",
                          $filename]);
        return;
    }

    # put here to avoid confusing Pod::Weaver
    my $h2 = '=head2';

    my $func_name = $command_name;
    $func_name =~ s/[^A-Za-z0-9]+/_/g;
    $func_name = "_$func_name";

    my $text = <<_;
This script has shell tab completion capability with support for several shells.

$h2 bash

To activate bash completion for this script, put:

 complete -C $command_name $command_name

in your bash startup (e.g. C<~/.bashrc>). Your next shell session will then
recognize tab completion for the command. Or, you can also directly execute the
line above in your shell to activate immediately.

You can also install L<App::BashCompletionProg> which makes it easy to add
completion for Perinci::CmdLine-based scripts. After you install the module and
put C<. ~/.bash-complete-prog> (or C<. /etc/bash-complete-prog>), you can just
run C<bash-completion-prog> and the C<complete> command will be added to your
C<~/.bash-completion-prog>. Your next shell session will then recognize tab
completion for the command.

$h2 tcsh

To activate tcsh completion for this script, put:

 complete $command_name 'p/*/`$command_name`/'

in your tcsh startup (e.g. C<~/.tcshrc>). Your next shell session will then
recognize tab completion for the command. Or, you can also directly execute the
line above in your shell to activate immediately.

$h2 zsh

To activate zsh completion for this script, put:

 $func_name() { read -l; local cl="\$REPLY"; read -ln; local cp="\$REPLY"; reply=(`COMP_LINE="\$cl" COMP_POINT="\$cp" $command_name`) }

 compctl -K $func_name $command_name

in your zsh startup (e.g. C<~/.zshrc>). Your next shell session will then
recognize tab completion for the command. Or, you can also directly execute the
line above in your shell to activate immediately.

_

    $document->children->push(
        Pod::Elemental::Element::Nested->new({
            command  => 'head1',
            content  => 'COMPLETION',
            children => [
                map { s/\n/ /g; Pod::Elemental::Element::Pod5::Ordinary->new({ content => $_ })} split /\n\n/, $text
            ],
        }),
    );
}

no Moose;
1;
# ABSTRACT: Add a COMPLETION section for Perinci::CmdLine-based scripts

__END__

=pod

=encoding UTF-8

=head1 NAME

Pod::Weaver::Section::Completion::PerinciCmdLine - Add a COMPLETION section for Perinci::CmdLine-based scripts

=head1 VERSION

This document describes version 0.05 of Pod::Weaver::Section::Completion::PerinciCmdLine (from Perl distribution Pod-Weaver-Section-Completion-PerinciCmdLine), released on 2014-11-23.

=head1 SYNOPSIS

In your C<weaver.ini>:

 [Completion::PerinciCmdLine]

=head1 DESCRIPTION

This section plugin adds a COMPLETION section for Perinci::CmdLine-based
scripts. The section contains information on how to activate shell tab
completion for the scripts.

=for Pod::Coverage weave_section

=head1 SEE ALSO

L<Perinci::CmdLine>

=head1 HOMEPAGE

Please visit the project's homepage at L<https://metacpan.org/release/Pod-Weaver-Section-Completion-PerinciCmdLine>.

=head1 SOURCE

Source repository is at L<https://github.com/perlancar/perl-Pod-Weaver-Section-BashCompletion-PerinciCmdLine>.

=head1 BUGS

Please report any bugs or feature requests on the bugtracker website L<https://rt.cpan.org/Public/Dist/Display.html?Name=Pod-Weaver-Section-Completion-PerinciCmdLine>

When submitting a bug or request, please include a test-file or a
patch to an existing test-file that illustrates the bug or desired
feature.

=head1 AUTHOR

perlancar <perlancar@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by perlancar@cpan.org.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
