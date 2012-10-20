package MT::Plugin::Admin::OMV::DisplayDBName;
# $Id$

use strict;
use MT 5;
use MT::Util;

use vars qw( $VENDOR $MYNAME $VERSION );
($VENDOR, $MYNAME) = (split /::/, __PACKAGE__)[-2, -1];
(my $revision = '$Rev$') =~ s/\D//g;
$VERSION = '0.02'. ($revision ? ".$revision" : '');

use constant {
    SHOW_ON_HEADER =>   1,
    SHOW_ON_FOOTER =>   2,
    SHOW_ON_BOTH =>     3,
};

use base qw( MT::Plugin );
my $plugin = __PACKAGE__->new ({
        name => $MYNAME,
        id => lc $MYNAME,
        key => lc $MYNAME,
        version => $VERSION,
        author_name => 'Open MagicVox.net',
        author_link => 'http://www.magicvox.net/',
        plugin_link => 'http://www.magicvox.net/archive/2012/04251702/', # blog
        doc_link => 'http://lab.magicvox.net/trac/mt-plugins/wiki/DisplayDBName', # trac
        description => <<HTMLHEREDOC,
<__trans phrase="Show the connecting database name on the header menu.">
HTMLHEREDOC
        system_config_template => "$MYNAME/config.tmpl",
        settings => new MT::PluginSettings ([
            [ 'show_on', { Default => SHOW_ON_HEADER, scope => 'system' } ],
            [ 'display_format', { Default => '%%Database%%@%%DBHost%%', scope => 'system' } ],
            [ 'link_href', { Default => undef, scope => 'system' } ],
        ]),
});
MT->add_plugin( $plugin );

### Registry
sub init_registry {
    my $plugin = shift;
    $plugin->registry ({
        callbacks => {
            'MT::App::CMS::template_source.header' => sub {
                5.0 <= $MT::VERSION
                    ? return _source_header_v5 (@_) : 0;
                4.0 <= $MT::VERSION
                    ? return _source_header_v4 (@_) : 0;
            },
            'MT::App::CMS::template_source.footer' => sub {
                5.0 <= $MT::VERSION
                    ? return _source_footer_v5 (@_) : 0;
                4.0 <= $MT::VERSION
                    ? return _source_footer_v4 (@_) : 0;
            },
        },
    });
}



### ヘッダに表示
sub _source_header_v5 {
    my ($cb, $app, $tmpl) = @_;

    my $display_format = $plugin->get_config_value ('display_format')
        or return;
    map {
        $display_format =~ s/%%$_%%/<mt:var name="config.$_" encode_html="1">/ig;
    } qw/ Database DBHost /;
    my $link_href = $plugin->get_config_value ('link_href')
        || '';
    map {
        $link_href =~ s/%%$_%%/MT::Util::encode_url($app->config($_))/ige;
    } qw/ Database DBHost /;
    my $show_on = $plugin->get_config_value ('show_on')
        || SHOW_ON_HEADER;
    ($show_on & SHOW_ON_HEADER)
        or return;

    my $old = quotemeta (<<'MTMLHEREDOC');
<ul id="utility-nav-list">
MTMLHEREDOC
    my $new = <<"MTMLHEREDOC";
<li style="padding-right:0.5em;">
<img src="<mt:var static_uri>plugins/$MYNAME/database.png" alt="Database" />
MTMLHEREDOC
    if (length $link_href) {
        $new .= <<"MTMLHEREDOC";
<a href="$link_href" style="padding:0;">$display_format</a></li>
MTMLHEREDOC
    } else {
        $new .= <<"MTMLHEREDOC";
$display_format</li>
MTMLHEREDOC
    }
    $$tmpl =~ s/($old)/$1$new/;
}

sub _source_header_v4 { _source_header_v5 (@_); }

### フッタに表示
sub _source_footer_v5 {
    my ($cb, $app, $tmpl) = @_;

    my $display_format = $plugin->get_config_value ('display_format')
        or return;
    map {
        $display_format =~ s/%%$_%%/<mt:var name="config.$_" encode_html="1">/ig;
    } qw/ Database DBHost /;
    my $link_href = $plugin->get_config_value ('link_href')
        || '';
    map {
        $link_href =~ s/%%$_%%/MT::Util::encode_url($app->config($_))/ige;
    } qw/ Database DBHost /;
    my $show_on = $plugin->get_config_value ('show_on')
        || SHOW_ON_HEADER;
    ($show_on & SHOW_ON_FOOTER)
        or return;

    my $old = quotemeta (<<'MTMLHEREDOC');
    </p>
  <!-- /Footer --></div>
MTMLHEREDOC
    my $new = <<"MTMLHEREDOC";
<__trans phrase="on">
<img src="<mt:var static_uri>plugins/$MYNAME/database.png" alt="Database" />
MTMLHEREDOC
    if (length $link_href) {
        $new .= <<"MTMLHEREDOC";
<a href="$link_href" style="padding:0;">$display_format</a>
MTMLHEREDOC
    } else {
        $new .= <<"MTMLHEREDOC";
$display_format
MTMLHEREDOC
    }
    $$tmpl =~ s/($old)/$new$1/;
}

sub _source_footer_v4 { _source_footer_v5 (@_); }

1;