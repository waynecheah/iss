'use strict';
// generated on 2014-04-21 using generator-gulp-webapp 0.0.7

var gulp        = require('gulp');
var runSequence = require('run-sequence');
var app_dir     = 'app';
var build_dir   = 'build';
var dist_dir    = 'dist';
var bower_dir   = 'app/bower_components';

// Load plugins
var $ = require('gulp-load-plugins')();

// CoffeeScript
gulp.task('coffee', function() {
    return gulp.src(app_dir+'/scripts/**/*.coffee')
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
    return gulp.src(app_dir+'/scripts/**/*.js')
        .pipe($.changed(app_dir+'/scripts'))
        .pipe($.jshint())
        .pipe($.jshint.reporter($.jshintStylish))
        .pipe($.size({ showFiles: true }));
});

// Sass
gulp.task('sass', function () {
    return gulp.src(app_dir+'/styles/**/*.scss')
        .pipe($.changed(build_dir+'/styles', { extension: '.css' }))
        .pipe($.sass({
            errLogToConsole: true,
            includePaths: [bower_dir+'/'],
            outputStyle: 'expanded',
            sourceComments: 'map'
        }))
        .pipe(gulp.dest(build_dir+'/styles'))
        .pipe($.size({ showFiles: true }));
});

// Styles
gulp.task('styles', function () {
    return gulp.src(app_dir+'/styles/**/*.css')
        .pipe($.changed(app_dir+'/styles'))
        .pipe($.autoprefixer('last 1 version'))
        .pipe(gulp.dest(app_dir+'/styles'))
        .pipe($.size({ showFiles: true }));
});

// Jade
gulp.task('jade', function() {
    gulp.src(app_dir+'/scripts/**/*.jade')
        .pipe($.changed(build_dir+'/scripts', { extension: '.html' }))
        .pipe($.jade({
            //debug: true,
            pretty: true
        }))
        .pipe(gulp.dest(build_dir+'/scripts/'))
        .pipe($.size({ showFiles: true }));

    return gulp.src(app_dir+'/*.jade')
        .pipe($.changed(build_dir, { extension: '.html' }))
        .pipe($.jade({
            //debug: true,
            pretty: true
        }))
        .pipe(gulp.dest(build_dir+'/'))
        .pipe($.size({ showFiles: true }));
});

// HTML
gulp.task('html', ['styles', 'scripts'], function () {
    var jsFilter = $.filter('**/*.js');
    var cssFilter = $.filter('**/*.css');

    return gulp.src('app/*.html')
        .pipe($.useref.assets())
        .pipe(jsFilter)
        .pipe($.uglify())
        .pipe(jsFilter.restore())
        .pipe(cssFilter)
        .pipe($.csso())
        .pipe(cssFilter.restore())
        .pipe($.useref.restore())
        .pipe($.useref())
        .pipe(gulp.dest('dist'))
        .pipe($.size({ showFiles: true }));
});

// Images
gulp.task('images', function () {
    return gulp.src(app_dir+'/images/**/*')
        .pipe($.cache($.imagemin({
            optimizationLevel: 3,
            progressive: true,
            interlaced: true
        })))
        .pipe(gulp.dest(dist_dir+'/images'))
        .pipe($.size({ showFiles: true }));
});

// Fonts
gulp.task('fonts', function () {
    return $.bowerFiles()
        .pipe($.filter('**/*.{eot,svg,ttf,woff}'))
        .pipe($.flatten())
        .pipe(gulp.dest('dist/fonts'))
        .pipe($.size({ showFiles: true }));
});

// Clean
gulp.task('clean-pro', function () {
    return gulp.src(dist_dir, { read: false }).pipe($.clean());
});
gulp.task('clean', function () {
    return gulp.src(build_dir, { read: false }).pipe($.clean());
});

// Open Application
/*gulp.task('open-browser', function(){
    return gulp.src('index.html')
        .pipe($.open('', {
            url: 'http://localhost:9000',
            app: 'Google Chrome Canary'
        }));
});*/

// Build
//gulp.task('build', ['html', 'images', 'fonts']);

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

// Default task
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
            gulp.src(app_dir+'/scripts/vendor/modernizr-2.7.1.min.js', { read: false }),
            { ignorePath: 'app', addRootSlash: false, starttag: '<!-- inject:head:{{ext}} -->' }
        ))
        .pipe($.inject(
            gulp.src([
                bower_dir+'/es5-shim/es5-shim.js',
                bower_dir+'/json3/lib/json3.min.js'
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
                app_dir+'/scripts/**/*.js',
                '!'+app_dir+'/scripts/vendor/modernizr-2.7.1.min.js',
                '!'+build_dir+'/styles/main.css',
                build_dir+'/styles/**/*.css',
                app_dir+'/styles/**/*.css',
                '!'+app_dir+'/styles/404.css'
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
        app_dir+'/images/**/*',
        app_dir+'/*.html'
    ], function (file) {
        return gulp.src(file.path).pipe($.connect.reload());
    }).on('change', changed);

    // Watch .coffee files
    gulp.watch([app_dir+'/scripts/**/*.coffee'], ['coffee'])
        .on('change', changed);

    // Watch .scss files
    gulp.watch(app_dir+'/styles/**/*.scss', ['sass']).on('change', changed);

    // Watch .jade files
    gulp.watch([app_dir+'/*.jade', app_dir+'/scripts/**/*.jade'], ['jade'])
        .on('change', changed);

    // watch index.html
    gulp.watch(build_dir+'/index.html', function(e){
        runSequence('inject', 'reload');
    }).on('change', changed);

    // Watch .js files
    gulp.watch(app_dir+'/scripts/**/*.js', ['scripts']);

    // Watch .css files
    gulp.watch(app_dir+'/styles/**/*.css', ['styles']);

    // Watch image files
    gulp.watch(app_dir+'/images/**/*', ['images']);

    // Watch bower files
    gulp.watch('bower.json', function(){
        runSequence('inject-bower', 'reload');
    }).on('change', changed);
});
