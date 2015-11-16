class EventsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_event, only: %i(show update destroy)

  def index
    @events = current_user.events.between(params['start'], params['end']) if (params['start'] && params['end'])
    @events ||= current_user.events

    respond_to do |format|
      format.html
      format.json do
        if params['start'] && params['end']
          render json: @events, start: params['start'], end: params['end']
        else
          render json: @events
        end
      end
    end
  end

  def all
    @events = Event.between(params['start'], params['end']) if (params['start'] && params['end'])
    @events ||= Event.all

    respond_to do |format|
      format.html
      format.json do
        if params['start'] && params['end']
          render json: @events, start: params['start'], end: params['end']
        else
          render json: @events
        end
      end
    end
  end

  def show
    @event = current_user.events.find(params[:id])
  end

  def new
    @event = current_user.events.new
  end

  def edit
    @event = current_user.events.find_by(id: params[:id])
    redirect_to all_calendar_path, notice: 'Вы не можете редактировать чужое событие' unless @event
  end

  def create
    @event = current_user.events.new(event_params)

    if @event.save
      redirect_to calendar_path, notice: 'Событие удачно создано.'
    else
      render action: :new
    end
  end

  def update
    @event = current_user.events.find(params[:id])
    if @event.update event_params
      redirect_to calendar_path, notice: 'Событие удачно обновлено.'
    else
      render action: :edit
    end
  end

  def destroy
    @event = current_user.events.find(params[:id])
    if @event.destroy
      redirect_to calendar_path, notice: 'Событие удалено.'
    else
      redirect_to calendar_path, notice: 'Что-то пошло не так, попробуйте еще раз.'
    end
  end

  private

  def event_params
    params.require(:event).permit(:title, :description, :starts_at, :ends_at, :repeats)
  end

  def find_event
    @event = current_user.events.find(params[:id])
  end
end
