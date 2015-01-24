'use strict'

angular.module('relativeDate', [])
  .value('now', new Date())
  .value('relativeDateTranslations', {
    just_now: 'just now'
    seconds_ago: '{{time}} seconds ago'
    a_minute_ago: 'a minute ago'
    minutes_ago: '{{time}} minutes ago'
    an_hour_ago: 'an hour ago'
    hours_ago: '{{time}} hours ago'
    a_day_ago: 'yesterday'
    days_ago: '{{time}} days ago'
    a_week_ago: 'a week ago'
    weeks_ago: '{{time}} weeks ago'
    a_month_ago: 'a month ago'
    months_ago: '{{time}} months ago'
    a_year_ago: 'a year ago'
    years_ago: '{{time}} years ago'
    over_a_year_ago: 'over a year ago'
    seconds_from_now: '{{time}} seconds from now'
    a_minute_from_now: 'a minute from now'
    minutes_from_now: '{{time}} minutes from now'
    an_hour_from_now: 'an hour from now'
    hours_from_now: '{{time}} hours from now'
    a_day_from_now: 'tomorrow'
    days_from_now: '{{time}} days from now'
    a_week_from_now: 'a week from now'
    weeks_from_now: '{{time}} weeks from now'
    a_month_from_now: 'a month from now'
    months_from_now: '{{time}} months from now'
    a_year_from_now: 'a year from now'
    years_from_now: '{{time}} years from now'
    over_a_year_from_now: 'over a year from now'
  })
  .filter 'relativeDate', ['$injector', '$filter', 'now', 'relativeDateTranslations', ($injector, $filter, now, relativeDateTranslations) ->
    if $injector.has('$translate')
      # Use angular-translate (or any service which implements .instant(id, params)) if it's available
      $translate = $injector.get('$translate')
    else
      # Simple polyfill for the angular-translate service
      $translate = {
        instant: (id, params) ->
          relativeDateTranslations[id].replace('{{time}}', params.time)
      }

    (date) ->
      date = new Date(date) unless date instanceof Date
      delta = null
      timeValue = null

      minute = 60
      hour = minute * 60
      day = hour * 24
      week = day * 7
      month = day * 30
      year = day * 365

      calculateDelta = ->
        delta = Math.round(Math.abs(now - date) / 1000)

      calculateDelta()

      if delta > day && delta < week
        # We're dealing with days now, so time becomes irrelevant
        date = new Date(date.getFullYear(), date.getMonth(), date.getDate(), 0, 0, 0)
        calculateDelta()

      switch
        when delta < 30 then translatePhrase = 'just_now'
        when delta < minute
          translatePhrase = 'seconds'
          timeValue = delta
        when delta < 2 * minute then translatePhrase = 'a_minute'
        when delta < hour
          translatePhrase = 'minutes'
          timeValue = Math.floor(delta / minute)
        when Math.floor(delta / hour) == 1 then translatePhrase = 'an_hour'
        when delta < day
          translatePhrase = 'hours'
          timeValue = Math.floor(delta / hour)
        when delta < day * 2 then translatePhrase = 'a_day'
        when delta < week
          translatePhrase = 'days'
          timeValue = Math.floor(delta / day)
        when Math.floor(delta / week) == 1 then translatePhrase = 'a_week'
        when delta < month
          translatePhrase = 'weeks'
          timeValue = Math.floor(delta / week)
        when Math.floor(delta / month) == 1 then translatePhrase = 'a_month'
        when delta < year
          translatePhrase = 'months'
          timeValue = Math.floor(delta / month)
        when Math.floor(delta / year) == 1 then translatePhrase = 'a_year'
        else translatePhrase = 'over_a_year'

      if translatePhrase == 'just_now'
        translateKey = translatePhrase
      else if now >= date
        translateKey = "#{translatePhrase}_ago"
      else
        translateKey = "#{translatePhrase}_from_now"

      $translate.instant(translateKey, { time: timeValue })
  ]
