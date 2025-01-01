class ConditionChartsController < ApplicationController
  before_action :authenticate_user!

  def index
    # 現在のユーザーのすべてのConditionデータを取得
    @q = current_user.conditions.ransack(params[:q])
    @all_q = Condition.joins(user: :teams)
             .where(teams: { id: current_user.teams.ids })
             .distinct
             .ransack(params[:all_q])
    @conditions = @q.result(distinct: true)
    @all_conditions = @all_q.result(distinct: true)

    @athletes = current_user.teams.includes(:users).flat_map(&:users).select { |user| user.role.athlete? }

    fields = [ :recorded_on, :fatigue_level, :mental_state, :body_temperature, :sleep_hours ]

    condition_data = if current_user.role.athlete?
      @conditions.pluck(*fields)
    elsif current_user.role.coach?
      @all_conditions.pluck(*fields)
    else
      [] # 万が一ロールが想定外の場合のデフォルト
    end

    # グラフデータを生成
    @chart1_data = {
      labels: condition_data.map { |recorded_on, *_| recorded_on.strftime("%Y-%m-%d") },
      datasets: [
        {
          type: "line",
          label: "肉体的疲労度",
          data: condition_data.map { |_, fatigue_level, *_| fatigue_level },
          borderColor: "#2196F3",
          backgroundColor: "#2196F3",
          yAxisID: "y"
        },
        {
          type: "line",
          label: "精神的疲労度",
          data: condition_data.map { |_, _, mental_state, *_| mental_state },
          borderColor: "#2DC653",
          backgroundColor: "#2DC653",
          yAxisID: "y"
        }
      ]
    }
    # グラフのオプション設定
    @chart1_options = {
      responsive: true,
      scales: {
        y: {
          type: "linear",
          display: true,
          position: "left",
          min: 0,
          max: 100
        }
      }
    }

    @chart2_data = {
      labels: condition_data.map { |recorded_on, *_| recorded_on.strftime("%Y-%m-%d") },
      datasets: [
        {
          type: "line",
          label: "体温",
          data: condition_data.map { |_, _, _, body_temperature, _| body_temperature },
          borderColor: "#D00000",
          backgroundColor: "#D00000",
          yAxisID: "y"
        },
        {
          type: "bar",
          label: "睡眠時間",
          data: condition_data.map { |_, _, _, _, sleep_hours| sleep_hours },
          borderColor: "#03045E",
          backgroundColor: "#0077B6",
          yAxisID: "y1"
        }
      ]
    }
    # グラフのオプション設定
    @chart2_options = {
      responsive: true,
      scales: {
        y: {
          type: "linear",
          display: true,
          position: "left",
          min: 33,
          max: 43
        },
        y1: {
          type: "linear",
          display: true,
          position: "right",
          min: 0,
          max: 10
        }
      }
    }
  end
end
