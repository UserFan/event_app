# == Schema Information
#
# Table name: events
#
#  id          :integer          not null, primary key
#  title       :string
#  starts_at   :datetime
#  ends_at     :datetime
#  all_day     :boolean
#  description :text
#  user_id     :integer
#  created_at  :datetime
#  updated_at  :datetime
#  repeats     :string
#

class Event < ActiveRecord::Base
  extend Enumerize

  enumerize :repeats, in: %i(all_day weekly monthly annually), predicates: true

  belongs_to :user

  validates :user, :title, :starts_at, :ends_at, :repeats, presence: true
  validates :title, length: { maximum: 255 }

  scope :between, -> (start_time, end_time) { where('ends_at > ? OR ends_at < ?', start_time, end_time) }

  def as_json(options = {})
    if !repeats?
      return basic_json
    else
      case repeats
      when 'weekly'
        event_start = Date.parse(starts_at.strftime('%Y-%m-%d'))
        dow = event_start.cwday
        dow = 0 if dow == 7
        return basic_json.merge(
          start: '0:00',
          end: '11:00',
          ranges: [{ start: (event_start - 1.day), end: ends_at }],
          dow: [dow]
        )
      when 'all_day'
        return basic_json
      when 'monthly'
        event_day = Date.parse(starts_at.strftime('%Y-%m-%d')).day
        calendar_end = Date.parse(options[:end])
        current_calendar = calendar_end - 15.days
        current_month = current_calendar.month
        current_year  = current_calendar.year
        current_month_event_date = Date.new(current_year, current_month, event_day)

        return basic_json.merge(
          start: current_month_event_date,
          end: current_month_event_date.end_of_day
        )

      when 'annually'
        calendar_end = Date.parse(options[:end])
        event_start  = Date.parse(starts_at.strftime('%Y-%m-%d'))
        if calendar_end.year > event_start.year
          return basic_json.merge(
            start: event_start.change(year: calendar_end.year),
            end: event_start.change(year: calendar_end.year)
          )
        else
          return basic_json.merge(
          end: event_start.change(year: calendar_end.year)
          )
        end
      end
    end
  end

  private

  def basic_json
    {
      id: id,
      title: title,
      description: description,
      start: starts_at,
      end: ends_at,
      allDay: true,
      user_id: user_id,
      url: Rails.application.routes.url_helpers.edit_event_path(id),
      color: '#63B8FF'
    }
  end
end
