use strict;
use warnings;
use Mojolicious::Lite;
use JSON::PP;

use Mojo::Util qw(secure_compare);
use JIRA::REST;
use Data::Dumper;
use URI::Split qw(uri_split uri_join);

# App instructions
get '/' => qw(index);
# -------------------------------------------------------------------- #
# Anything works, a long as it's GET and POST
any [ 'GET', 'POST' ] => '/time' => sub {
        shift->render(json => { now => scalar(localtime) });
    };
# -------------------------------------------------------------------- #
any [ 'GET', 'POST' ] => '/login' => sub {
        my $self = shift;

        # Grab the request parameters
        my $username = $self->param('username');
        my $password = $self->param('password');
        # check user and pass with jira rest


        # get jira rest api from config file
        my $config = plugin Config => { file => 'jirarest.conf' };
        my $api = $config->{jirarest_api};

        # try login to jira rest
        my $jirarest = JIRA::REST->new($api, $username, $password);
        my $query;
        eval {
            $query = $jirarest->GET("/myself");
        };

        if ($@) {
            return $self->render(json => { "login result" => 'log in fail', "api"=>$api }, status => 403);
        } else {
            $self->session(jirarest_api => $api);
            $self->session(jirarest => $jirarest);
            $self->session(logged_in => 1);
            $self->session(username => $username);
            $self->session(password => $password);
            return $self->render(json => { "login result" => 'loged in success', "api"=>$api }, status => 200);
        }

    };

# -------------------------------------------------------------------- #
# Authentication
under(sub {
    my $self = shift;

    #my $res=  $self->req->url->to_abs->userinfo;

    # Have access
    if ($self->session('logged_in')) {
        return 1;
    }
    # Do not have access
    $self->render(json =>
        { status => "error", data => { message => "Credentials mis-match" } }
    );
    return undef;
});

# -------------------------------------------------------------------- #
# Just a GET request
any [ 'GET', 'POST' ] => '/get' => sub {
        my $self = shift;
        my $path = $self->param('path');

       # my $jirarest = $self->session('jirarest');
        #my $json = $jirarest->GET(get_path($path));
        my $api = $self->session('jirarest_api');
        my $username = $self->session('username');
        my $password = $self->session('password');
        my $jirarest = JIRA::REST->new($api, $username, $password);
        my $query;
        eval {
            $query = $jirarest->GET("/rest/api/2/filter/favourite");
        };

        if ($@) {

        }else{

        }
        my $json = JSON->new;
        #$json->escape_slash([1]);
        my $json_text = $json->escape_slash(0)->encode($query);
        $self->render(data =>$json_text);

    };
# -------------------------------------------------------------------- #
# Just a GET request
get '/hello' => sub {
        my $self = shift;
        $self->render(json =>
            { "greeting" => "hello", "user" => "jason", "jirarest_api" => $self->session('jirarest_api') });
    };
# -------------------------------------------------------------------- #
# Just a GET request
get '/status' => sub {
        my $self = shift;

        if ($self->session('logged_in')) {
            $self->render(json => { "status " => "logged in " });
        } else {
            $self->render(json => { "status " => "not logged in " });
        }

    };


# -------------------------------------------------------------------- #
any [ 'GET', 'POST' ] => '/logout' => sub {
        my $self = shift;

        if ($self->session('logged_in')) {
            # Expire the session (deleted upon next request)
            $self->session(expires => 1);
            $self->render(json => { "logout result" => " logged out sucessfully " });
        } else {
            $self->render(json => { "logout result" => " you didn't log in " });
        }

    };



# -------------------------------------------------------------------- #
# Required


app->start;
# ==================================================================== #



# -------------------------------------------------------------------- #
# get_path : remove http://xxx.com part from url path, this is required by JIRS::REST lib
# 'https://jeanreve.atlassian.net/rest/api/2/filter/favourite' to '/rest/api/2/filter/favourite''


sub get_path{
    my $url = $_[0];
    my ($scheme, $auth, $path, $query, $frag) = uri_split($url);
    return uri_join(undef, undef, $path, $query, $frag);
}

# -------------------------------------------------------------------- #
# check : login in by jira rest api
sub jira_login {
    my ($username, $password) = @_;
    my $jira = JIRA::REST->new('https://jira.example.net', 'myuser', 'mypass');
    return ($username eq 'admin' && $password eq 'admin');

}



__DATA__

@@ index.html.ep

<pre>
Try: 

    $ curl -v -X GET --user 'user:523487063f1011e68442002500f18b6d' \
         http://127.0.0.1:3000/v1/time
    $ curl -v -X POST --user 'user:523487063f1011e68442002500f18b6d' \
         http://127.0.0.1:3000/v1/time
    $ curl -v -X GET --user 'user:523487063f1011e68442002500f18b6d' \
         http://127.0.0.1:3000/v1/epoch
    $ curl -v -X POST --user 'user:523487063f1011e68442002500f18b6d' \
         http://127.0.0.1:3000/v1/epoch

    All except the last should work.
</pre>
