'use strict';
// generated on 2014-06-13 using generator-gulp-webapp 0.1.0

var gulp        = require('gulp');
var runSequence = require('run-sequence');
var app_dir     = 'app';
var build_dir   = 'build';
var dist_dir    = 'dist';
var bower_dir   = app_dir+'/bower_components';
var fonts_dir   = app_dir+'/fonts';
var images_dir  = app_dir+'/images';
var partial_dir = app_dir+'/partials';
var scripts_dir = app_dir+'/scripts';
var styles_dir  = app_dir+'/styles';
var deploy_url  = 'https://s3-ap-southeast-1.amazonaws.com/innerzon';
var psiStrategy = 'mobile'; // desktop

var aws = {
    "key": "AKIAI7XFGR6PRKUQGIHA",
    "secret": "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",
    "bucket": "innerzon",
    "region": "ap-southeast-1",
    "distributionId": "E2HDNN5ZDII5U5"
};

// Load plugins
var $ = require('gulp-load-plugins')();

// CoffeeScript
gulp.task('coffee', function() {
    return gulp.src(scripts_dir+'/**/*.coffee')
        .pipe($.changed(build_dir+'/scripts', { extension: '.js' }))
        .pipe($.coffeelint())
        .pipe($.coffeelint.reporter())
        .pipe($.coffee({
            bare: true,
            sourceMap: true
        })/*.on('error', $.gutil.log)*/)
        .pipe(gulp.dest(build_dir+'/scripts'))
        .pipe($.size({ showFiles: true }));
});

// Scripts
gulp.task('scripts', function () {
    return gulp.src(scripts_dir+'/**/*.js')
        .pipe($.changed(scripts_dir))
        .pipe($.jshint())
        .pipe($.jshint.reporter(require('jshint-stylish')))
        .pipe($.jshint.reporter('fail'))
        .pipe($.size({ showFiles: true }));
});

// Sass
gulp.task('sass', function () {
    return gulp.src(styles_dir+'/**/*.scss')
        .pipe($.changed(build_dir+'/styles', { extension: '.css' }))
        .pipe($.sass({
            errLogToConsole: true,
            includePaths: [bower_dir+'/'],
            outputStyle: 'expanded',
            sourceMap: 'sass',
            sourceComments: 'map'
        }))
        .pipe(gulp.dest(build_dir+'/styles'))
        .pipe($.size({ showFiles: true }));
});

// Styles
gulp.task('styles', function () {
    return gulp.src(styles_dir+'/**/*.css')
        .pipe($.changed(styles_dir))
        .pipe($.autoprefixer('last 1 version', {
            map: false
        }))
        .pipe(gulp.dest(styles_dir))
        .pipe($.size({ showFiles: true }));
});

// Jade (use for development build)
gulp.task('jade', function () {
    return gulp.src([app_dir+'/**/*.jade', '!'+bower_dir+'/**/*', '!'+partial_dir+'/**/*'])
        .pipe($.changed(build_dir, { extension: '.html' }))
        .pipe($.jade({
            //debug: true,
            pretty: true
        }))
        .pipe(gulp.dest(build_dir))
        .pipe($.size({ showFiles: true }));
});
// Jade (use for production distribute build)
gulp.task('jade2', function () {
    gulp.src(app_dir+'/*.jade')// Only compile all jade layouts to html, skip minifier process for inject & useref/min
        //.pipe($.replace(/include\spartials\/(\w+)/g, 'include ../build/partials/$1.html')) // TODO(remove): temporary 
        .pipe($.jade({
            pretty: true
        }))
        .pipe(gulp.dest(build_dir+'/'))
        .pipe($.size({ showFiles: true }));

    // process all jade files direct to distribute folder except Layouts and Partials
    var files = [
            app_dir+'/**/*.jade', '!'+app_dir+'/*.jade', '!'+bower_dir+'/**/*',
            '!'+app_dir+'/includes/**/*', '!'+partial_dir+'/**/*'
    ];
    return gulp.src(files)
        .pipe($.jade())
        .pipe(gulp.dest(dist_dir))
        .pipe($.size({ showFiles: true }));
});
// Partial views changed need update layout (use for development build)
gulp.task('partial', function () {
    return gulp.src([app_dir+'/*.jade'])
        .pipe($.jade({ pretty: true }))
        .pipe(gulp.dest(build_dir))
        .pipe($.size({ showFiles: true }));
});

// HTML useref/usemin (only apply to Layout type html)
gulp.task('html', ['styles', 'scripts'], function () { // [styles, scripts] tasks may only use in development
    return gulp.src(build_dir+'/*.html')// find all html Layout, format & optimize css/js, then concat all blocks
        .pipe($.useref.assets({searchPath: '{'+build_dir+','+app_dir+'}'}))
        .pipe($.if('*.js', $.ngAnnotate()))
        .pipe($.if('*.js', $.uglify()))
        .pipe($.if('*.css', $.autoprefixer('last 1 version', 'BlackBerry 10', 'Android 4', { map: false })))
        .pipe($.if('*.css', $.csso()))
        .pipe($.useref.restore())
        .pipe($.useref())
        .pipe(gulp.dest(dist_dir))
        .pipe($.size({ showFiles: true }));
});

// Cdnizer (use for production distribute build)
gulp.task('cdnizer', function () {
    return gulp.src(dist_dir+'/*.html')
        .pipe($.cdnizer([{
            file: 'bower_components/modernizr/modernizr.js',
            package: 'modernizr',
            cdn: '//cdnjs.cloudflare.com/ajax/libs/modernizr/${ major }.${ minor }.${ patch }/modernizr.min.js'
        }, {
            file: 'bower_components/es5-shim/es5-shim.js',
            package: 'es5-shim',
            cdn: '//cdnjs.cloudflare.com/ajax/libs/es5-shim/${ major }.${ minor }.${ patch }/es5-shim.min.js'
        }, {
            file: 'bower_components/json3/lib/json3.js',
            package: 'json3',
            cdn: '//cdnjs.cloudflare.com/ajax/libs/json3/${ major }.${ minor }.${ patch }/json3.min.js'
        }]))
        .pipe(gulp.dest(dist_dir))
        .pipe($.size({ showFiles: true }));
});

// HTML-Minifier (use for production distribute build)
gulp.task('htmlmin', function () {
    return gulp.src([app_dir+'/**/*.html', '!'+bower_dir+'/**/*', dist_dir+'/**/*.html'])
        .pipe($.htmlmin({
            removeComments: false,
            collapseWhitespace: true,
            collapseBooleanAttributes: true,
            minifyJS: true,
            minifyCSS: true,
            processScripts: ['text/ng-template', 'text/x-handlebars-template']
        }))
        .pipe(gulp.dest(dist_dir))
        .pipe($.size({ showFiles: true }));
});

// Images
gulp.task('images', function () {
    return gulp.src(images_dir+'/**/*')
//        .pipe($.cache($.imagemin({
//            optimizationLevel: 3,
//            progressive: true,
//            interlaced: true
//        })))
        .pipe(gulp.dest(dist_dir+'/images'))
        .pipe($.size({ showFiles: true }));
});

// Fonts
gulp.task('fonts', function () {
    var streamqueue = require('streamqueue');
    return streamqueue({objectMode: true},
            $.bowerFiles(),
            gulp.src(fonts_dir+'/**/*')
        )
        .pipe($.filter('**/*.{eot,svg,ttf,woff}'))
        .pipe($.flatten())
        .pipe(gulp.dest(dist_dir+'/fonts'))
        .pipe($.size({ showFiles: true }));
});

// Others assets
gulp.task('extras', function () {
    var files = [
            app_dir+'/*.*', '!'+app_dir+'/.buildignores', '!'+app_dir+'/.DS_Store', '!'+app_dir+'/*.jade'
    ];
    return gulp.src(files, { dot: true })
        .pipe(gulp.dest(dist_dir))
        .pipe($.size({ showFiles: true }));
});

// Revisioning
gulp.task('rev', function () {
    return gulp.src(dist_dir+'/**')
        .pipe($.revAll({ ignore: ['.DS_Store', '404.html', 'index.html'] }))
        .pipe(gulp.dest(dist_dir+'/_s3'));
//        .pipe($.gzip())
//        .pipe($.s3(aws, {
//            gzippedOnly: true,
//            headers: { 'Cache-Control': 'max-age=315360000, no-transform, public' }
//        }))
//        .pipe($.cloudfront(aws));
});

// PageSpeed Insights
gulp.task('psi', function (cb) {
    var psi = require('psi');
    psi({
        nokey: 'true', // or use key: ‘YOUR_API_KEY’
        url: deploy_url,
        strategy: psiStrategy
    }, cb);
});

// Clean
gulp.task('clean-all', function () {
    return gulp.src([build_dir, dist_dir], { read: false }).pipe($.rimraf());
});
gulp.task('clean', function () {
    return gulp.src(build_dir, { read: false }).pipe($.rimraf());
});

// Open Application
/*gulp.task('open-browser', function(){
    return gulp.src('index.html')
        .pipe($.open('', {
            url: 'http://localhost:9000',
            app: 'Google Chrome Canary'
        }));
});*/


// -------
//  Build
// -------
gulp.task('build', function (){
    var compiles = ['coffee', 'sass', 'jade2'];
    var optimize = ['html', 'images', 'fonts', 'extras'];
    runSequence('clean-all', 'partial', compiles, 'inject', optimize, 'cdnizer', 'htmlmin', 'rev', function () {
        return gulp.src('dist/**/*').pipe($.size({title: 'build', gzip: true}));
    });
});

// Angular-gettext Translation
gulp.task('pot', function () {
    return gulp.src([build_dir+'/**/*.html', build_dir+'/scripts/**/*.js'])
        .pipe($.angularGettext.extract('template.pot'))
        .pipe(gulp.dest(app_dir+'/po/'));
});
gulp.task('translations', function () {
    return gulp.src(app_dir+'/po/**/*.po')
        .pipe($.angularGettext.compile({
            //format: 'json',
            module: 'glApp'
        }))
        .pipe(gulp.dest(app_dir+'/scripts'));
});

// --------------
//  Default task
// --------------
gulp.task('default', function (){
    runSequence('clean', ['coffee','sass','jade'], 'inject', 'watch');
});


// Connect
gulp.task('connect', $.connect.server({
    root: [build_dir, app_dir],
    port: 9000,
    livereload: true,
    open: { browser: 'Google Chrome Canary' }
}));
gulp.task('reload', function () {
    return gulp.src(build_dir+'/index.html').pipe($.connect.reload());
});

// Bower components
gulp.task('bower-files', function(){
    console.log($.bowerFiles({read: false}));
});
// Inject bower
gulp.task('inject-bower', function(){
    return gulp.src(build_dir+'/index.html')
        .pipe($.inject(
            $.bowerFiles({ read: false, debugging:false }), {
                ignorePath: app_dir,
                addRootSlash: false,
                starttag: '<!-- bower:{{ext}} -->',
                endtag: '<!-- endbower -->'
            }
        ))
});
// Inject bower, stylesheet, javascript and web component reference
gulp.task('inject', function(){
    return gulp.src(build_dir+'/index.html')
        .pipe($.inject(
            gulp.src(bower_dir+'/modernizr/modernizr.js'
            , { read: false }), {
                ignorePath: app_dir,
                addRootSlash: false,
                starttag: '<!-- inject:head:{{ext}} -->'
            }
        ))
        .pipe($.inject(
            gulp.src([
                bower_dir+'/es5-shim/es5-shim.js',
                bower_dir+'/json3/lib/json3.js'
            ], { read: false }), {
                ignorePath: app_dir,
                addRootSlash: false,
                starttag: '<!--[if lt IE 9]>',
                endtag: '<![endif]-->'
            }
        ))
        .pipe($.inject(
            $.bowerFiles({ read: false, debugging:false }), {
                ignorePath: app_dir,
                addRootSlash: false,
                starttag: '<!-- bower:{{ext}} -->',
                endtag: '<!-- endbower -->'
            }
        ))
        .pipe($.inject(
            gulp.src([
                build_dir+'/scripts/**/*.js',
                scripts_dir+'/**/*.js',
                build_dir+'/styles/**/*.css',
                styles_dir+'/**/*.css',
                '!'+styles_dir+'/404.css'
            ], { read: false }),
            { ignorePath: [app_dir, build_dir], addRootSlash: false }
        ))
        .pipe(gulp.dest(build_dir));
});

// Watch
gulp.task('watch', ['connect'], function () {
    function changed (file) {
        console.log('[changed] '+file.path);
    } // changed

    // Watch for source files changes
    gulp.watch([
        build_dir+'/*.html',
        '!'+build_dir+'/index.html',
        build_dir+'/scripts/**/*.html',
        build_dir+'/styles/**/*.css',
        build_dir+'/scripts/**/*.js',
        images_dir+'/**/*',
        app_dir+'/*.html'
    ], function (file) {
        return gulp.src(file.path).pipe($.connect.reload());
    }).on('change', changed);

    gulp.watch(scripts_dir+'/**/*.js', ['scripts']); // Watch .js files
    gulp.watch(styles_dir+'/**/*.css', ['styles']); // Watch .css files
    gulp.watch(images_dir+'/**/*', ['images']); // Watch image files

    // Watch .coffee files
    gulp.watch([scripts_dir+'/**/*.coffee'], ['coffee'])
        .on('change', changed);
    // Watch .scss files
    gulp.watch(styles_dir+'/**/*.scss', ['sass']).on('change', changed);
    // Watch .jade files
    gulp.watch([app_dir+'/*.jade', scripts_dir+'/**/*.jade', '!'+partial_dir+'/**/*.jade'], ['jade'])
        .on('change', changed);
    gulp.watch(partial_dir+'/**/*.jade', ['partial'])
        .on('change', changed);

    // watch index.html
    gulp.watch(build_dir+'/index.html', function(e){
        runSequence('inject', 'reload');
    }).on('change', changed);
    // Watch bower files
    gulp.watch('bower.json', function(){
        runSequence('inject-bower', 'reload');
    }).on('change', changed);
});
