#!/usr/bin/with-contenv bashio

# Get configuration
THEME=$(bashio::config 'redlib_default_theme')
FRONT_PAGE=$(bashio::config 'redlib_default_front_page')
LAYOUT=$(bashio::config 'redlib_default_layout')
WIDE=$(bashio::config 'redlib_default_wide')
USE_HLS=$(bashio::config 'redlib_default_use_hls')
HIDE_HLS=$(bashio::config 'redlib_default_hide_hls_notification')
AUTOPLAY=$(bashio::config 'redlib_default_autoplay_videos')
COMMENT_SORT=$(bashio::config 'redlib_default_comment_sort')
POST_SORT=$(bashio::config 'redlib_default_post_sort')
SHOW_NSFW=$(bashio::config 'redlib_default_show_nsfw')
BLUR_NSFW=$(bashio::config 'redlib_default_blur_nsfw')
DISABLE_CONFIRMATION=$(bashio::config 'redlib_default_disable_visit_reddit_confirmation')
PUSHSHIFT=$(bashio::config 'redlib_pushshift_frontend')

# Set environment variables
export REDLIB_DEFAULT_THEME="${THEME}"
export REDLIB_DEFAULT_FRONT_PAGE="${FRONT_PAGE}"
export REDLIB_DEFAULT_LAYOUT="${LAYOUT}"
export REDLIB_DEFAULT_WIDE="${WIDE}"
export REDLIB_DEFAULT_USE_HLS="${USE_HLS}"
export REDLIB_DEFAULT_HIDE_HLS_NOTIFICATION="${HIDE_HLS}"
export REDLIB_DEFAULT_AUTOPLAY_VIDEOS="${AUTOPLAY}"
export REDLIB_DEFAULT_COMMENT_SORT="${COMMENT_SORT}"
export REDLIB_DEFAULT_POST_SORT="${POST_SORT}"
export REDLIB_DEFAULT_SHOW_NSFW="${SHOW_NSFW}"
export REDLIB_DEFAULT_BLUR_NSFW="${BLUR_NSFW}"
export REDLIB_DEFAULT_DISABLE_VISIT_REDDIT_CONFIRMATION="${DISABLE_CONFIRMATION}"

if bashio::config.has_value 'redlib_pushshift_frontend'; then
    export REDLIB_PUSHSHIFT_FRONTEND="${PUSHSHIFT}"
fi

bashio::log.info "Starting Redlib..."

# Start Redlib
exec /usr/local/bin/redlib --address 0.0.0.0 --port 8090
