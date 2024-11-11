=begin
=転職編集画面 by Foo




==更新履歴
  Date     Version Author Comment
==15/09/03 2.0.2   トリス 統合J～U S
==17/11/01 2.2.0  ひまわり　SSS,SS項目の追加。
=end

#==============================================================================
# ■ NWConst::JobChange
#==============================================================================
module NWConst::JobChange 
  CLASS_TYPE = [
    ["一般職", "上級職", "最上級職", "封印職", "禁職"],
    ["一般種", "上級種", "最上級種", "封印種", "禁種"]
  ]
  CLASS_LANK = [1,2,3,4,5,6]

  # 転職条件を満たしていない時の行頭メッセージ
  UNKNOWN_NEED_ITEM      = "転職アイテムを所持して"
  UNKNOWN_NEED_CLASS     = "以下をマスターにする必要があります"
  UNKNOWN_SELECT_CLASS   = "以下のどれかをマスターにする必要があります"
  UNKNOWN_DIFFERENT_KIND = "種族が違います"
  # クラスチェンジ決定
  CLASS_CHANGE_RESULT  = ["%sは%sの職に就いた！", "%sは%sになった！"]    
  # クラスをマスターした時に表示するアイコンID
  CLASS_MASTER_ICON_ID = 191
end

# 重複防止用ネームスペース
module Foo; module JobChange; end; end

#==============================================================================
# ■ Foo::JobChange::EnableCheck
#==============================================================================
module Foo
  module JobChange
    module EnableCheck
      #--------------------------------------------------------------------------
      # ● 転職可能判定
      #--------------------------------------------------------------------------
      def class_change_enable?(id)
        job = $data_classes[id]
        experience_class?(job) || (need_item?(job) && need_class?(job) && select_class?(job) && different_tribe?(job))
      end

      #--------------------------------------------------------------------------
      # ● 職業名表示判定
      #--------------------------------------------------------------------------
      def class_show_enable?(id)
        ShowChecker.class_show_enable?(id)
      end

      #--------------------------------------------------------------------------
      # ● 経験済みクラス？
      #--------------------------------------------------------------------------
      def experience_class?(job)
        actor.level_list.key?(job.id)
      end

      #--------------------------------------------------------------------------
      # ● 転職アイテムを所持しているか？
      #--------------------------------------------------------------------------
      def need_item?(job)
        EnableCheck.need_item?(job)
      end

      #--------------------------------------------------------------------------
      # ● 要求経験職を満たしているか？
      #--------------------------------------------------------------------------
      def need_class?(job)
        return true if job.need_jobchange_class.empty?

        job.need_jobchange_class.all? do |obj, _i|
          actor.level_list.fetch(obj[:id], 0) >= obj[:lv]
        end
      end

      #--------------------------------------------------------------------------
      # ● 選択経験職を満たしているか？
      #--------------------------------------------------------------------------  
      def select_class?(job)
        return true if job.select_jobchange_class.empty?

        job.select_jobchange_class.all? do |jobs|
          jobs.any? { |obj| actor.level_list.fetch(obj[:id], 0) >= obj[:lv] }
        end
      end

      #--------------------------------------------------------------------------
      # ● 種族違いではない？
      #--------------------------------------------------------------------------
      def different_tribe?(job)
        !(job.tribe? && (job.class_lank == 1) && need_item?(job))
      end

      #--------------------------------------------------------------------------
      # ● 不明名の取得
      #--------------------------------------------------------------------------
      def unknown_name
        "？？？？？？"
      end

      class << self
        def init
          @need_item = []
        end

        def need_item?(job)
          return @need_item[job.id] unless @need_item[job.id].nil?

          @need_item[job.id] = (job.need_jobchange_item.empty? || job.need_jobchange_item.all? do |item_id|
            $game_party.has_item?($data_items[item_id])
          end)
          @need_item[job.id]
        end
      end
      init
    end

    #==============================================================================
    # ■ Foo::JobChange::ShowChecker
    #==============================================================================
    class ShowChecker
      include EnableCheck
      attr_writer :check_show_actor

      #--------------------------------------------------------------------------
      # ● 全ての判定対象クラスID
      #--------------------------------------------------------------------------
      def class_id
        NWConst::Class::JOB_RANGE.to_a + NWConst::Class::TRIBE_RANGE.to_a
      end

      #--------------------------------------------------------------------------
      # ● 現在の判定対象アクター
      #--------------------------------------------------------------------------
      def actor
        @check_show_actor
      end

      class << self
        def check_class_show_enable
          EnableCheck.init
          @obj ||= new
          @class_show_test = []
          @class_show = []

          members = $game_party.include_members
          show_classes = class_id.select do |id|
            members.any? do |member|
              @obj.check_show_actor = member
              @obj.class_change_enable?(id)
            end
          end

          show_classes.each do |class_id|
            @class_show[class_id] = true
          end
          @obj.check_show_actor = nil
        end

        def actors_num
          $game_party.include_members.size
        end

        def class_id
          NWConst::Class::JOB_RANGE.to_a + NWConst::Class::TRIBE_RANGE.to_a
        end

        def class_show_enable?(id)
          @class_show[id]
        end

        #--------------------------------------------------------------------------
        # ● 表示可能か
        #--------------------------------------------------------------------------
        def class_show_text(id, actor_name, actor_enable)
          result = ""
          class_show_test(id).each_with_index do |data, i|
            case i
            when 0
              text = ""
              text += (data > 0 ? $data_classes[id].name : "？？？？？？")
              if data > 0
                text += "　　#{actor_name}:転職#{actor_enable ? '可能' : '不可能'}" if actor_name
                text += "\n\n全キャラ:#{actors_num}"
                text += "　　転職可能キャラ:#{data}"
                text += "　　転職不可能キャラ:#{actors_num - data}"
                text += "\n\n転職可能キャラ:\n"
              end
              result += text
            when 1
              result += format("　%s", data)
            else
              result += format("、%s", data)
            end
          end
          result
        end

        def class_show_test(id)
          return @class_show_test[id] if @class_show_test[id]

          @class_show_test[id] = [0]

          $game_party.include_members.each do |member|
            @obj.check_show_actor = member
            next unless @obj.class_change_enable?(id)

            @class_show_test[id][0] += 1
            @class_show_test[id].push(member.name)
          end

          @class_show_test[id]
        end
      end
    end
  end
end

#==============================================================================
# ■ Foo::JobChange::Window_Information
#==============================================================================
class Foo::JobChange::Window_Information < Window_Base
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize
    super(0, Graphics.height - fitting_height(1), 160, fitting_height(1))
    refresh
    activate
  end
  #--------------------------------------------------------------------------
  # ● リフレッシュ（新規）
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    draw_information
  end  
  #--------------------------------------------------------------------------
  # ● 情報の表示（新規）
  #--------------------------------------------------------------------------
  def draw_information
    change_color(normal_color)
    rect = Rect.new(0,0,self.contents.width,line_height)
    Help.job_change.each{|text|
      draw_text(rect, text)
      rect.y += line_height    
    }
  end
end

#==============================================================================
# ■ Foo::JobChange::Window_Help
#==============================================================================
class Foo::JobChange::Window_Help < Window_Base
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize
    super(0, 0, Graphics.width - 160, fitting_height(1))
    @text = ""
  end
  #--------------------------------------------------------------------------
  # ● テキストの設定（新規）
  #--------------------------------------------------------------------------
  def text=(t)
    @text = t
    refresh
  end
  #--------------------------------------------------------------------------
  # ● リフレッシュ（新規）
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    draw_help
  end
  #--------------------------------------------------------------------------
  # ● ヘルプメッセージの表示（新規）
  #--------------------------------------------------------------------------
  def draw_help
    change_color(normal_color)
    draw_text(contents.rect, @text)
  end
end

#==============================================================================
# ■ Foo::JobChange::Window_Popup
#==============================================================================
class Foo::JobChange::Window_Popup < Window_Command
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize
    super((Graphics.width - window_width) / 2, 200)
    self.z = 500
    @actor_ok = true
    hide.deactivate
  end
  #--------------------------------------------------------------------------
  # ● ウィンドウ幅の取得（オーバーライド）
  #--------------------------------------------------------------------------
  def window_width
    160
  end
  #--------------------------------------------------------------------------
  # ● ウィンドウ高さの取得（オーバーライド）
  #--------------------------------------------------------------------------
  def window_height
    line = @actor_ok ? 3 : 2
    fitting_height(line)
  end
  #--------------------------------------------------------------------------
  # ● アクター選択確認フラグの設定
  #--------------------------------------------------------------------------
  def actor_ok=(ok)
    @actor_ok = ok
    refresh
  end
  #--------------------------------------------------------------------------
  # ● コマンドリストの作成（オーバーライド）
  #--------------------------------------------------------------------------
  def make_command_list
    if @actor_ok
      add_command("職業を変更する", :actor_ok)
      add_command("種族を変更する", :actor_ok)
      add_command("キャンセル", :actor_cancel)
    else
      add_command("変更を決定する", :class_ok)
      add_command("キャンセル", :class_cancel)      
    end
  end
  #--------------------------------------------------------------------------
  # ● キャンセル処理の有効状態を取得（オーバーライド）
  #--------------------------------------------------------------------------
  def cancel_enabled?
    if @actor_ok
      handle?(:actor_cancel)
    else
      handle?(:class_cancel)    
    end
  end
  #--------------------------------------------------------------------------
  # ● キャンセルハンドラの呼び出し（オーバーライド）
  #--------------------------------------------------------------------------
  def call_cancel_handler
    if @actor_ok
      call_handler(:actor_cancel)
    else
      call_handler(:class_cancel)    
    end
  end
  #--------------------------------------------------------------------------
  # ● リフレッシュ（オーバーライド）
  #--------------------------------------------------------------------------
  def refresh
    self.height = window_height
    super
  end
end

#==============================================================================
# ■ Foo::JobChange::Window_ActorStatus
#==============================================================================
class Foo::JobChange::Window_ActorStatus < Window_Base
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize
    super(160, 360, 480, 120)
    @actor_id = -1
  end
  #--------------------------------------------------------------------------
  # ● アクターIDの設定
  #--------------------------------------------------------------------------
  def actor_id=(actor_id)
    @actor_id = actor_id
    refresh
  end
  #--------------------------------------------------------------------------
  # ● アクターの取得
  #--------------------------------------------------------------------------
  def actor
    1 <= @actor_id ? $game_actors[@actor_id] : nil
  end
  #--------------------------------------------------------------------------
  # ● リフレッシュ（新規）
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    unless actor.nil?
      draw_actor_status1
      draw_actor_status2
    end
  end
  #--------------------------------------------------------------------------
  # ● アクターのステータス表示（顔グラ~種族）（新規）
  #--------------------------------------------------------------------------
  def draw_actor_status1
    draw_actor_face(actor, 0, 0)
    
    # 残りWIDTH領域132
    rect1 = Rect.new(96, 0, 84, line_height)
    rect2 = Rect.new(rect1.x+rect1.width, rect1.y, 48, rect1.height)
    lv_str = "Lv:%d"

    change_color(normal_color)
    draw_text(rect1, actor.name) # 名前だけ少し大きく
    temp_font_size = contents.font.size
    contents.font.size = 22
    draw_actor_level(actor, rect2.x, rect2.y,  :base)

    rect1.y += line_height + 8
    rect2.y += line_height + 8
    change_color(tp_gauge_color2)
    draw_text(rect1, actor.class.name)
    draw_actor_level(actor, rect2.x, rect2.y, :class)
    
    rect1.y += line_height
    rect2.y += line_height
    change_color(mp_gauge_color2)
    draw_text(rect1, actor.tribe.name)
    draw_actor_level(actor, rect2.x, rect2.y, :tribe)
    contents.font.size = temp_font_size
  end
  #--------------------------------------------------------------------------
  # ● アクターのステータス表示（HP~luc）（新規）
  #--------------------------------------------------------------------------
  def draw_actor_status2
    x = 230
    y = 20
    w = 42
    h = 22
    inc_x = 76
    inc_y = 24
    rect1 = Rect.new(0, 0, w, h)
    rect2 = Rect.new(0 + w, 0, w, h)
    status_word  = [Vocab::hp_a, Vocab::mp_a, Vocab::tp_a]
    status_word += (0..5).collect{|i| Vocab::params_a(i)}
    status_param = (0...8).collect{|i|actor.param(i)}
    status_param.insert(2, actor.max_tp)
    
    temp_font_size = contents.font.size
    contents.font.size = 22
    change_color(system_color)
    status_word.each_with_index{|word, i|
      rect1.x = inc_x * (i % 3) + x
      rect1.y = inc_y * (i / 3) + y
      draw_text(rect1, word)
    }
    change_color(normal_color)
    status_param.each_with_index{|param, i|
      rect2.x = inc_x * (i % 3) + x + 42 - 10
      rect2.y = inc_y * (i / 3) + y
      dp = param >= 1000000 ? param.give_unit_floor(4) : param
      draw_text(rect2, dp, 2)
    }    
    contents.font.size = temp_font_size
  end
end


#==============================================================================
# ■ Foo::JobChange::Window_Actors
#==============================================================================
class Foo::JobChange::Window_Actors < Window_Command
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(status)
    @status = status
    make_id_list
    super(0, fitting_height(1))
    activate
  end
  #--------------------------------------------------------------------------
  # ● ウィンドウ幅の取得
  #--------------------------------------------------------------------------
  def window_width
    Graphics.width
  end
  #--------------------------------------------------------------------------
  # ● ウィンドウ高さの取得
  #--------------------------------------------------------------------------
  def window_height
    360 - fitting_height(1)
  end
  #--------------------------------------------------------------------------
  # ● 桁数の取得
  #--------------------------------------------------------------------------
  def col_max
    return 4
  end
  #--------------------------------------------------------------------------
  # ● 横に項目が並ぶときの空白の幅を取得
  #--------------------------------------------------------------------------
  def spacing
    return 8
  end
  #--------------------------------------------------------------------------
  # ● 選択中のアクターIDを取得
  #--------------------------------------------------------------------------
  def select_actor_id
     self.index != -1 ? @actors[self.index] : -1
  end
  #--------------------------------------------------------------------------
  # ● 項目の選択
  #--------------------------------------------------------------------------
  def select(index)
    super
    @status.actor_id = @actors[index]
  end
  #--------------------------------------------------------------------------
  # ● コマンドリストの作成
  #--------------------------------------------------------------------------
  def make_command_list
    @actors.each{|id|
      add_command($game_actors[id].name, :ok)
    }
  end
  #--------------------------------------------------------------------------
  # ● 待機メンバーIDリストの作成
  #--------------------------------------------------------------------------
  def make_id_list(category = :all_category)
    r = $game_party.include_members
    r.select! { |a|a.actor.actor_categories.include?(category) } unless category == :all_category
    @actors = r.map(&:id)
  end
  #--------------------------------------------------------------------------
  # ● ソート
  #--------------------------------------------------------------------------
  def sort(category)
    make_category = [:id, :name].include?(category) ? :all_category : category
    sort_category = [:id, :name].include?(category) ? category : :id
    make_id_list(make_category)
    method = "sort_by_#{sort_category}".to_sym
    send(method)
  end
  #--------------------------------------------------------------------------
  # ● ソート（ID順）
  #--------------------------------------------------------------------------
  def sort_by_id
    @actors = ( $game_party.all_members.map(&:id).select{ |m| @actors.include?(m) } + @actors.sort_by { |id| $game_actors[id].sort_obj }).uniq
  end
  #--------------------------------------------------------------------------
  # ● ソート（名前５０音順）
  #--------------------------------------------------------------------------
  def sort_by_name
    @actors.sort_by!{|id| $game_actors[id].name}
  end
  #--------------------------------------------------------------------------
  # ● リフレッシュ
  #--------------------------------------------------------------------------
  def refresh
    super
    select(0) unless self.index == -1
  end

  def draw_item(index)
    color = $game_party.exist_party_actor_id?(@actors[index]) ? system_color : normal_color
    change_color(color, command_enabled?(index))
    draw_text(item_rect_for_text(index), command_name(index), alignment)
  end
end

#==============================================================================
# ■ Foo::JobChange::Window_SortEval
#==============================================================================
class Foo::JobChange::Window_SortEval < Window_Base
  attr_accessor :eval_id
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(actors)
    super(480, 0, 160, fitting_height(1))
    @actors = actors
    self.z = 101
    @eval_id = 0
    make_actor_categories
    activate
  end
  #--------------------------------------------------------------------------
  # ● 評価方法の取得（新規）
  #--------------------------------------------------------------------------
  def eval
    return eval_array[@eval_id]
  end
  #--------------------------------------------------------------------------
  # ● 評価方法配列の取得（新規）
  #--------------------------------------------------------------------------
  def eval_array
    default_eval_array + @actor_categories
  end
  #--------------------------------------------------------------------------
  # ● 基本評価方法配列の取得（新規）
  #--------------------------------------------------------------------------
  def default_eval_array
    [:id, :name]
  end
  #--------------------------------------------------------------------------
  # ● 基本評価方法配列の取得（新規）
  #--------------------------------------------------------------------------
  def make_actor_categories
    @actor_categories = $game_party.include_members.collect { |m| m.actor.actor_categories }.flatten.uniq
    @actor_categories.sort_by! { |a| NWConst::PTEdit::CATEGORY_PRIORITY.index(a) }
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新（オーバーライド）
  #--------------------------------------------------------------------------
  def update
    super
    process_eval
  end
  #--------------------------------------------------------------------------
  # ● ソート方法の切り替え（新規）
  #--------------------------------------------------------------------------
  def process_eval
    return unless @actors.active
    return unless Input.trigger?(:Y) || Input.trigger?(:Z)
    @eval_id = (@eval_id + 1) % eval_array.size if Input.trigger?(:Z)
    @eval_id = (@eval_id - 1 + eval_array.size) % eval_array.size if Input.trigger?(:Y)
    Input.update
    Sound.play_ok
    refresh
  end
  #--------------------------------------------------------------------------
  # ● リフレッシュ（新規）
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    draw_eval
    @actors.sort(eval)
    @actors.refresh
  end
  #--------------------------------------------------------------------------
  # ● ソート方法の表示（新規）
  #--------------------------------------------------------------------------
  def draw_eval
    texts = {
      :id => "ID順",
      :name => "名前順"
    }
    text = texts.include?(eval) ? texts[eval] : eval.to_s
    change_color(system_color)
    rect = Rect.new(0,0,self.contents.width,line_height)
    draw_text(rect, text, 1)
  end
end

#==============================================================================
# ■ Foo::JobChange::Window_ClassStatus
#==============================================================================
class Foo::JobChange::Window_ClassStatus < Window_Base
  #------------------------------------------------------------------------
  # ● モジュールインクルード
  #------------------------------------------------------------------------
  include Foo::JobChange::EnableCheck
  #------------------------------------------------------------------------
  # ● 公開インスタンス変数
  #------------------------------------------------------------------------
  attr_writer :actor_id
  attr_writer :class_id
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize
    super(160, fitting_height(1) * 2, Graphics.width - 160, Graphics.height - fitting_height(1) * 2)
    @actor_id = -1
    @class_id = -1
    hide.deactivate
  end
  #--------------------------------------------------------------------------
  # ● アクターの取得
  #--------------------------------------------------------------------------
  def actor
    @actor_id != -1 ? $game_actors[@actor_id] : nil
  end
  #--------------------------------------------------------------------------
  # ● ジョブの取得
  #--------------------------------------------------------------------------
  def job
    @class_id != -1 ? $data_classes[@class_id] : nil
  end
  #--------------------------------------------------------------------------
  # ● リフレッシュ
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    return unless @actor_id != -1 && @class_id != -1 
    if class_change_enable?(@class_id)
      draw_status
    else
      draw_unknown
    end
  end
  #--------------------------------------------------------------------------
  # ● 標準表示用矩形の取得
  #--------------------------------------------------------------------------
  def standard_rect(y = 0, line = 1)
    Rect.new(4, y, self.contents.width - 4, self.line_height * line)
  end  
  #--------------------------------------------------------------------------
  # ● 不明職業の描画
  #--------------------------------------------------------------------------
  def draw_unknown
    y = 0
    y = draw_unknown_different_kind(y)
    y = draw_unknown_need_item(y)
    y = draw_unknown_need_class(y)
    y = draw_unknown_select_class(y)
  end
  #--------------------------------------------------------------------------
  # ● 不明職業の種族判定描画
  #--------------------------------------------------------------------------
  def draw_unknown_different_kind(y)
    return y unless job.tribe? && (job.class_lank == 1)
    rect = standard_rect(y, 1)
    r = Rect.new(rect.x, rect.y, rect.width, line_height)
    reset_font_settings
    draw_text(r, NWConst::JobChange::UNKNOWN_DIFFERENT_KIND)
    
    return rect.y + rect.height    
  end
  #--------------------------------------------------------------------------
  # ● 不明職業の要求アイテム描画
  #--------------------------------------------------------------------------
  def draw_unknown_need_item(y)
    return y if job.need_jobchange_item.empty?
    reset_font_settings
    rect = standard_rect(y, ((job.need_jobchange_item.size + 1) / 2) + 2)
    r = Rect.new(rect.x, rect.y, rect.width, line_height)
    result = job.need_jobchange_item.all?{|item_id| $game_party.has_item?($data_items[item_id])}
    draw_text(r, NWConst::JobChange::UNKNOWN_NEED_ITEM + (result ? "います" : "いません"))
    r.y += line_height
    r.width /= 2
    job.need_jobchange_item.each_with_index{|item_id, i|
      if $game_party.has_item?($data_items[item_id])
        name = $data_items[item_id].name
        change_color(system_color)
      else
        name = unknown_name
        change_color(normal_color, false)
      end
      draw_text(r, name)
      r.x = (r.x + r.width) % rect.width
      r.y += line_height if (i % 2) == 1
    }
    
    return rect.y + rect.height
  end
  #--------------------------------------------------------------------------
  # ● 不明職業の要求経験職描画
  #--------------------------------------------------------------------------
  def draw_unknown_need_class(y)
    return y if job.need_jobchange_class.empty?
    rect = standard_rect(y, (job.need_jobchange_class.size + 1) / 2 + 2)
    r = Rect.new(rect.x, rect.y, rect.width, line_height)
    reset_font_settings
    draw_text(r, NWConst::JobChange::UNKNOWN_NEED_CLASS)
    
    ox = r.x
    oy = r.y + line_height
    job.need_jobchange_class.each_with_index{|obj, i|
      draw_unknown_need_or_select_class(ox, oy, r, obj, i)
    }
    
    return rect.y + rect.height
  end
  #--------------------------------------------------------------------------
  # ● 不明職業の選択経験職描画
  #--------------------------------------------------------------------------
  def draw_unknown_select_class(y)
    return y if job.select_jobchange_class.empty?
    rect = standard_rect(y, (job.select_jobchange_class.size + 1) / 2 + 2)
    r = Rect.new(rect.x, rect.y, rect.width, line_height)
    job.select_jobchange_class.each do |jobs|
      reset_font_settings
      draw_text(r, NWConst::JobChange::UNKNOWN_SELECT_CLASS)
      r.y += line_height
      ys = jobs.map.with_index do |obj, i|
        draw_unknown_need_or_select_class(r.x, r.y, r, obj, i)
      end
      r.y = ys.last + line_height * 2
    end
    rect.y + rect.height
  end
  #--------------------------------------------------------------------------
  # ● 経験職描画
  #--------------------------------------------------------------------------
  def draw_unknown_need_or_select_class(ox, oy, r, obj, i)
    ox += (r.width / 2 * (i % 2))
    oy += (r.height * (i / 2))
    name = class_show_enable?(obj[:id]) ? $data_classes[obj[:id]].name : unknown_name
    color = class_change_enable?(obj[:id]) ? [system_color] : [normal_color, false]
    change_color(*color)
    class_level = actor ? actor.level_list[obj[:id]] : nil
    max_lv = $data_classes[obj[:id]].max_lv
    if !class_level.nil? && max_lv <= class_level
      draw_icon(NWConst::JobChange::CLASS_MASTER_ICON_ID, ox, oy)
      ox += 24
    end
    draw_text(ox, oy, contents_width / 2, line_height, name)
    oy
  end
  #--------------------------------------------------------------------------
  # ● ステータスの描画
  #--------------------------------------------------------------------------
  def draw_status
    y = 0
    y = draw_job_name(y)
    y = draw_horz_line(y)
    y = draw_job_desc(y, 0)
    y = draw_horz_line(y)
    y = draw_job_param(y)    
    y = draw_horz_line(y)
    y = draw_job_desc(y, 1)    
  end
  #--------------------------------------------------------------------------
  # ● 水平線の描画
  #--------------------------------------------------------------------------
  def draw_horz_line(y)
    line_y = y + (8 / 2) - 1
    contents.fill_rect(0, line_y, contents_width, 2, line_color)
    return y + 8
  end  
  #--------------------------------------------------------------------------
  # ● 水平線の色を取得
  #--------------------------------------------------------------------------
  def line_color
    color = normal_color
    color.alpha = 48
    color
  end
  #--------------------------------------------------------------------------
  # ● ジョブ名の描画
  #--------------------------------------------------------------------------
  def draw_job_name(y)
    rect = standard_rect(y)
    rect.width -= 60
    reset_font_settings
    draw_text(rect, job.name)
    rect.x += rect.width
    draw_actor_class_level(actor, rect.x, rect.y, @class_id, normal_color)
    
    rect.y + rect.height
  end
  #--------------------------------------------------------------------------
  # ● ジョブ説明の描画
  #--------------------------------------------------------------------------
  def draw_job_desc(y, num)
    desc_text = NWConst::JobChange::JOB_DESC_TEXT[@class_id]
    desc = desc_text[num] if desc_text
    return y + line_height unless desc
    
    rect = standard_rect(y, desc.size)
    r = Rect.new(rect.x, rect.y, rect.width, line_height)
    desc.each_with_index{|text, i|
      draw_text_job_desc(r, text)
      r.y += line_height
    }
    return rect.y + rect.height
  end
  #--------------------------------------------------------------------------
  # ● ジョブ説明用テキスト描画
  #--------------------------------------------------------------------------
  def draw_text_job_desc(rect, text)
    reset_font_settings
    text = convert_escape_characters(text)
    pos = {:x => rect.x, :y => rect.y, :new_x => rect.x, :height => line_height}
    set_auto_font_size(text, rect.width)
    process_character(text.slice!(0, 1), text, pos) until text.empty?
  end
  #--------------------------------------------------------------------------
  # ● フォントの自動縮小サイズを決定
  #--------------------------------------------------------------------------
  def set_auto_font_size(text, width)
    before_text = text.gsub(/\e\w(?:\[\d*\])?/, "")
    contents.font.size -= 1 while (width + 10) < self.text_size(before_text).width
  end
  #--------------------------------------------------------------------------
  # ● ジョブパラメータの描画
  #--------------------------------------------------------------------------
  def draw_job_param(y)
    rect = standard_rect(y, 3)
    rect_width =  rect.width / 3
    rect_height = rect.height / 3
    rect1 = Rect.new(0, 0, rect_width - 70, rect_height)
    rect2 = Rect.new(0, 0, rect_width - rect1.width - 10, rect_height)
    
    reset_font_settings
    change_color(system_color)
    param_names.each_with_index{|name, i|
      rect1.x = rect.x + rect_width  * (i % 3)
      rect1.y = rect.y + rect_height * (i / 3)
      draw_text(rect1, name)
    }
    change_color(normal_color)
    job_params.each_with_index{|param, i|
      rect2.x = rect.x + rect1.width + rect_width * (i % 3)
      rect2.y = rect.y + rect_height * (i / 3)
      param += 100 if i == 2
      draw_text(rect2, "#{param}%", 2)
    }
    return rect.y + rect.height
  end
  #--------------------------------------------------------------------------
  # ● ジョブパラメータの取得
  #--------------------------------------------------------------------------
  def job_params
    params = Array.new(8){1.0}
    job.features.each{|ft|
      next unless ft.code == NWFeature::FEATURE_PARAM
      params[ft.data_id] *= ft.value
    }
    params.collect!{|param| (param * 100.0).round}    
    tp = job.features.select{|ft|
      ft.code == NWFeature::FEATURE_BATTLER_ABILITY && ft.data_id == NWFeature::Battler::INCREASE_TP && ft.value[:per]
    }.inject(0){|sum, f|
      sum += f.value[:plus] ? f.value[:num] : -f.value[:num]
    }
    params.insert(2, tp)
    params
  end
  #--------------------------------------------------------------------------
  # ● パラメータ名配列の取得
  #--------------------------------------------------------------------------
  def param_names
    ["最大ＨＰ", "最大ＭＰ", "最大ＳＰ",
      "攻撃力", "防御力", "魔力",
      "精神力", "素早さ", "器用さ"]
  end
end

#==============================================================================
# ■ Foo::JobChange::Window_ClassName
#==============================================================================
class Foo::JobChange::Window_ClassName < Window_Command
  #------------------------------------------------------------------------
  # ● モジュールインクルード
  #------------------------------------------------------------------------
  include Foo::JobChange::EnableCheck
  #------------------------------------------------------------------------
  # ● 公開インスタンス変数
  #------------------------------------------------------------------------
  attr_writer :class_type_id
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(status)
    @status = status
    @actor_id = -1
    @class_type_id = -1
    @class_lank = -1
    @cache = {}
    @class_ids = {}
    super(0, 96)
    hide.deactivate
  end
  #--------------------------------------------------------------------------
  # ● ウィンドウ幅の取得
  #--------------------------------------------------------------------------
  def window_width
    160
  end
  #--------------------------------------------------------------------------
  # ● ウィンドウ高さの取得
  #--------------------------------------------------------------------------
  def window_height
    Graphics.height - 96
  end
  #--------------------------------------------------------------------------
  # ● 標準パディングサイズの取得
  #--------------------------------------------------------------------------
  def standard_padding
    6
  end
  #--------------------------------------------------------------------------
  # ● 項目の選択（オーバーライド）
  #--------------------------------------------------------------------------
  def select(index)
    super
    @status.class_id = select_class_id
    @status.refresh
  end
  #--------------------------------------------------------------------------
  # ● 表示用クラスランクを設定
  #--------------------------------------------------------------------------
  def class_lank=(lank)
    @class_lank = lank
    refresh
    select(0)
  end
  #--------------------------------------------------------------------------
  # ● アクターの取得
  #--------------------------------------------------------------------------
  def actor
    return nil if @actor_id == -1
    $game_actors[@actor_id]
  end
  #--------------------------------------------------------------------------
  # ● 選択中のクラスID取得
  #--------------------------------------------------------------------------
  def select_class_id
    current_ext || -1
  end
  #--------------------------------------------------------------------------
  # ● 表示用クラスIDの取得
  #--------------------------------------------------------------------------
  def class_id
    return [] if @class_type_id == -1

    @class_ids[[@class_type_id, @class_lank]] ||=
      [NWConst::Class::JOB_RANGE, NWConst::Class::TRIBE_RANGE].at(@class_type_id).sort_by {|id|$data_classes[id].sort_obj}.select do |id|
        $data_classes[id].class_lank == @class_lank && (need_item?($data_classes[id]) || experience_class?($data_classes[id]))
      end
  end

  #--------------------------------------------------------------------------
  # ● コマンドリストの作成（オーバーライド）
  #--------------------------------------------------------------------------
  def make_command_list
    return unless @actor_id != -1 && @class_type_id != -1
    class_id.each do |id|
      add_command($data_classes[id].name, :ok, class_change_enable?(id), id)
    end
  end

  def class_change_enable?(id)
    @cache[id] ||= super
  end

  def actor_id=(other)
    return if @actor_id == other

    @actor_id = other
    @cache = {}
    @class_ids = {}
  end
  #--------------------------------------------------------------------------
  # ● 項目の描画（オーバーライド）
  #--------------------------------------------------------------------------
  def draw_item(index)
    change_color(normal_color, command_enabled?(index))
    change_color(tp_gauge_color2) if actor.class_id == command_ext(index)
    change_color(mp_gauge_color2) if actor.tribe_id == command_ext(index)
    rect = item_rect_for_text(index)
    rect.width -= 18
    draw_text_autosizing(rect, command_name(index), alignment)
    class_level = actor.level_list.fetch(command_ext(index), 0)
    max_lv = $data_classes[command_ext(index)].max_lv
    draw_icon(NWConst::JobChange::CLASS_MASTER_ICON_ID, rect.width, rect.y) if max_lv <= class_level
  end

  #--------------------------------------------------------------------------
  # ● フレーム更新
  #--------------------------------------------------------------------------
  def update
    super
    if $TEST && active && Input.press?(:F6)
      checker = Foo::JobChange::ShowChecker
      if self.instance_of?(Foo::JobChange::Window_ClassName)
        msgbox checker.class_show_text(select_class_id, actor.name,
                                       class_change_enable?(select_class_id))
      else
        msgbox checker.class_show_text(select_class_id, nil, nil)
      end
    end
  end
end

#==============================================================================
# ■ Foo::JobChange::Window_ClassType
#==============================================================================
class Foo::JobChange::Window_ClassType < Window_HorzCommand
  #------------------------------------------------------------------------
  # ● 公開インスタンス変数
  #------------------------------------------------------------------------
  attr_writer :class_type_id
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(class_name)
    @class_name = class_name
    @class_type_id = -1
    super(0, fitting_height(1))
    hide.deactivate
  end
  #--------------------------------------------------------------------------
  # ● ウィンドウ幅の取得
  #--------------------------------------------------------------------------
  def window_width
    Graphics.width
  end
  #--------------------------------------------------------------------------
  # ● 桁数の取得
  #--------------------------------------------------------------------------
  def col_max
    return class_type.size
  end
  #--------------------------------------------------------------------------
  # ● 項目の選択
  #--------------------------------------------------------------------------
  def select(index)
    super
    @class_name.class_lank = class_lank
  end
  #--------------------------------------------------------------------------
  # ● コマンドリストの作成
  #--------------------------------------------------------------------------
  def make_command_list
    if @class_type_id != -1
      class_type.each{|type| add_command(type, :empty)}
    end
  end
  #--------------------------------------------------------------------------
  # ● クラスタイプの取得
  #--------------------------------------------------------------------------  
  def class_type
    tmp = NWConst::JobChange::CLASS_TYPE[@class_type_id].dup
    tmp.delete_at(4) unless $game_switches[NWConst::Sw::OPEN_CLASS_LANK5]
    tmp.delete_at(3) unless $game_switches[NWConst::Sw::OPEN_CLASS_LANK4]
    tmp.delete_at(2) unless $game_switches[NWConst::Sw::OPEN_CLASS_LANK3]
    tmp.delete_at(1) unless $game_switches[NWConst::Sw::OPEN_CLASS_LANK2]
    return tmp
  end
  #--------------------------------------------------------------------------
  # ● 選択中のクラスタイプに対応したランクを取得
  #--------------------------------------------------------------------------  
  def class_lank
    tmp = NWConst::JobChange::CLASS_LANK.dup
    tmp.delete_at(4) unless $game_switches[NWConst::Sw::OPEN_CLASS_LANK5]
    tmp.delete_at(3) unless $game_switches[NWConst::Sw::OPEN_CLASS_LANK4]
    tmp.delete_at(2) unless $game_switches[NWConst::Sw::OPEN_CLASS_LANK3]
    tmp.delete_at(1) unless $game_switches[NWConst::Sw::OPEN_CLASS_LANK2]
    return tmp[self.index]
  end
  #--------------------------------------------------------------------------
  # ● 決定ボタンが押されたときの処理（SE削除）
  #--------------------------------------------------------------------------
  def process_ok
    if current_item_enabled?
      Input.update
      deactivate
      call_ok_handler
    end
  end
  #--------------------------------------------------------------------------
  # ● キャンセルボタンが押されたときの処理（SE削除）
  #--------------------------------------------------------------------------
  def process_cancel
    Input.update
    deactivate
    call_cancel_handler
  end
end

#==============================================================================
# ■ Foo::JobChange::Window_PopupResult
#==============================================================================
class Foo::JobChange::Window_PopupResult < Window_Base
  #------------------------------------------------------------------------
  # ● 公開インスタンス変数
  #------------------------------------------------------------------------
  attr_writer :actor_id
  attr_writer :class_type_id
  attr_writer :class_id  
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize
    super(0, 0, 100, 100)
    @actor_id = -1
    @class_type_id = -1
    @class_id = -1
    @ok_handler = nil
    self.z = 500
    hide.deactivate
  end
  #--------------------------------------------------------------------------
  # ● 決定ハンドラの設定
  #--------------------------------------------------------------------------
  def set_ok_handler(handler)
    @ok_handler = handler
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新処理（オーバーライド）
  #--------------------------------------------------------------------------
  def update
    super
    if active && Input.trigger?(:C)
      Input.update      
      @ok_handler.call unless @ok_handler.nil?
    end
  end
  #--------------------------------------------------------------------------
  # ● リフレッシュ
  #--------------------------------------------------------------------------
  def refresh
    text = NWConst::JobChange::CLASS_CHANGE_RESULT[@class_type_id]
    text = sprintf(text, $game_actors[@actor_id].name, $data_classes[@class_id].name)
    self.width = text_size(text).width + standard_padding * 2 + 10
    self.height = fitting_height(1)
    self.x = (Graphics.width - self.width) / 2
    self.y = (Graphics.height - self.height) / 2
    create_contents
    contents.clear
    reset_font_settings
    draw_text(contents.rect, text, 1)
  end
end  
  
#==============================================================================
# ■ Scene_JobChange
#==============================================================================
class Scene_JobChange < Scene_ActorSelectBase
  #--------------------------------------------------------------------------
  # ● 開始処理
  #--------------------------------------------------------------------------
  def start
    check_class_show_enable
    super
    @change_class_type_id = -1
    @change_class_actor_id = -1
  end
  #--------------------------------------------------------------------------
  # ● 表示可否の事前チェック
  #--------------------------------------------------------------------------
  def check_class_show_enable
    Foo::JobChange::ShowChecker.check_class_show_enable
  end
  #--------------------------------------------------------------------------
  # ● 全ウィンドウの作成
  #--------------------------------------------------------------------------
  def create_all_window
    super
    create_popup_window
    create_class_status_window
    create_class_name_window
    create_class_type_window
    create_result_popup_window
  end
  #--------------------------------------------------------------------------
  # ● ポップアップウィンドウの作成
  #--------------------------------------------------------------------------
  def create_popup_window
    @popup_window = Foo::JobChange::Window_Popup.new
    @popup_window.set_handler(:actor_ok, method(:process_popup_actor_ok))
    @popup_window.set_handler(:actor_cancel, method(:process_popup_actor_cancel))
    @popup_window.set_handler(:class_ok, method(:process_class_ok))
    @popup_window.set_handler(:class_cancel, method(:process_class_ok_cancel))
  end
  #--------------------------------------------------------------------------
  # ● 選択アクターの決定
  #--------------------------------------------------------------------------
  def process_popup_actor_ok
    @change_class_type_id = @popup_window.index
    @change_class_actor_id = @actors_window.select_actor_id
    #
    @information_window.hide.deactivate
    @popup_window.hide.deactivate
    @actor_status_window.hide.deactivate
    @actors_window.hide.deactivate
    @sort_eval_window.hide.deactivate
    @help_window.width = Graphics.width
    #
    class_type_name = ["職業", "種族"].at(@change_class_type_id)
    @help_window.text = "#{change_actor.name}の変更する#{class_type_name}を選択してください"
    @class_status_window.show.activate
    @class_status_window.actor_id = @change_class_actor_id
    @class_type_window.show.activate
    @class_type_window.class_type_id = @change_class_type_id 
    @class_type_window.refresh
    @class_type_window.select(0)
    @class_name_window.show.activate
    @class_name_window.class_type_id = @change_class_type_id
    @class_name_window.actor_id = @change_class_actor_id
    @class_name_window.refresh
    @class_name_window.select(0)
  end
  #--------------------------------------------------------------------------
  # ● 選択アクターの決定キャンセル
  #--------------------------------------------------------------------------
  def process_popup_actor_cancel
    @change_class_type_id = -1
    @change_class_actor_id = -1
    @popup_window.hide.deactivate
    @actors_window.activate
  end
  #--------------------------------------------------------------------------
  # ● 選択クラスの決定
  #--------------------------------------------------------------------------
  def process_class_ok
    if @change_class_type_id == 0
      change_actor.change_class(@class_name_window.select_class_id, :class)
    elsif @change_class_type_id == 1
      change_actor.change_class(@class_name_window.select_class_id, :tribe)
    end
    change_actor.recover_all
    @popup_window.hide.deactivate
    @result_popup_window.show.activate
    @result_popup_window.actor_id = @change_class_actor_id
    @result_popup_window.class_type_id = @change_class_type_id
    @result_popup_window.class_id = @class_name_window.select_class_id
    @result_popup_window.refresh
  end
  #--------------------------------------------------------------------------
  # ● 選択クラスの決定キャンセル
  #--------------------------------------------------------------------------
  def process_class_ok_cancel
    @popup_window.hide.deactivate
    @class_name_window.activate
    @class_type_window.activate
  end
  #--------------------------------------------------------------------------
  # ● アクターステータスウィンドウの作成
  #--------------------------------------------------------------------------
  def create_actor_status_window
    @actor_status_window = Foo::JobChange::Window_ActorStatus.new
  end

  def process_actor_ok
    @popup_window.show.activate
    @popup_window.actor_ok = true
    @popup_window.select(0)
  end
  #--------------------------------------------------------------------------
  # ● クラスステータスウィンドウの作成
  #--------------------------------------------------------------------------
  def create_class_status_window
    @class_status_window = Foo::JobChange::Window_ClassStatus.new
  end
  #--------------------------------------------------------------------------
  # ● クラス選択ウィンドウの作成
  #--------------------------------------------------------------------------
  def create_class_name_window
    @class_name_window = Foo::JobChange::Window_ClassName.new(@class_status_window)
    @class_name_window.set_handler(:ok, method(:process_class_ok_check))
    @class_name_window.set_handler(:cancel, method(:process_class_cancel))
  end
  #--------------------------------------------------------------------------
  # ● クラス選択決定の確認
  #--------------------------------------------------------------------------
  def process_class_ok_check
    @class_type_window.deactivate
    @popup_window.show.activate
    @popup_window.actor_ok = false
    @popup_window.select(0)    
  end
  #--------------------------------------------------------------------------
  # ● クラス選択のキャンセル
  #--------------------------------------------------------------------------
  def process_class_cancel
    #
    @popup_window.hide.deactivate
    @class_status_window.hide.deactivate
    @class_type_window.hide.deactivate
    @class_name_window.hide.deactivate
    @result_popup_window.hide.deactivate
    #
    @help_window.width = Graphics.width - 160
    @help_window.text = "キャラクターを選択してください"
    @information_window.show.activate
    @actor_status_window.show.activate
    @actors_window.show.activate
    @actors_window.select(0)
    @sort_eval_window.show.activate
  end 
  #--------------------------------------------------------------------------
  # ● クラスタイプ選択ウィンドウの作成
  #--------------------------------------------------------------------------
  def create_class_type_window
    @class_type_window = Foo::JobChange::Window_ClassType.new(@class_name_window)
  end
  #--------------------------------------------------------------------------
  # ● リザルトポップアップウィンドウの作成
  #--------------------------------------------------------------------------
  def create_result_popup_window
    @result_popup_window = Foo::JobChange::Window_PopupResult.new
    @result_popup_window.set_ok_handler(method(:process_class_cancel))
  end
  #--------------------------------------------------------------------------
  # ● 変更対象アクターの取得
  #--------------------------------------------------------------------------
  def change_actor
    @change_class_actor_id != -1 ? $game_actors[@change_class_actor_id] : nil
  end
end

#==============================================================================
# ■ Foo::JobChange::LibWindow_ClassName
#==============================================================================
class Foo::JobChange::LibWindow_ClassName < Foo::JobChange::Window_ClassName
  #--------------------------------------------------------------------------
  # ● 転職可能判定
  #--------------------------------------------------------------------------
  def class_change_enable?(id)
    class_show_enable?(id)
  end

  def experience_class?(job)
    class_show_enable?(job.id)
  end

  #--------------------------------------------------------------------------
  # ● 項目の描画
  #--------------------------------------------------------------------------
  def draw_item(index)
    change_color(normal_color, command_enabled?(index))
    rect = item_rect_for_text(index)
    rect.width -= 24
    draw_text(rect, command_name(index), alignment)
  end
  #--------------------------------------------------------------------------
  # ● 決定ボタンが押されたときの処理
  #--------------------------------------------------------------------------
  def process_ok
  end
end
#==============================================================================
# ■ Foo::JobChange::LibWindow_ClassStatus
#==============================================================================
class Foo::JobChange::LibWindow_ClassStatus < Foo::JobChange::Window_ClassStatus
  #--------------------------------------------------------------------------
  # ● 転職可能判定
  #--------------------------------------------------------------------------
  def class_change_enable?(id)
    return class_show_enable?(id)
  end

  #--------------------------------------------------------------------------
  # ● ジョブ名の描画
  #--------------------------------------------------------------------------
  def draw_job_name(y)
    rect = standard_rect(y)
    rect.width -= 60
    reset_font_settings
    draw_text(rect, job.name)
    rect.x += rect.width
    
    return rect.y + rect.height
  end
  #--------------------------------------------------------------------------
  # ● 不明職業の種族判定描画
  #--------------------------------------------------------------------------
  def draw_unknown_different_kind(y)
    return y
  end
  #--------------------------------------------------------------------------
  # ● 現在の判定対象アクター
  #--------------------------------------------------------------------------
  def actor
    nil
  end
end
#==============================================================================
# ■ Scene_JobShow
#==============================================================================
class Scene_JobShow < Scene_JobChange
  #--------------------------------------------------------------------------
  # ● 全ウィンドウの作成
  #--------------------------------------------------------------------------
  def create_all_window
    check_class_show_enable
    @change_class_type_id = $game_temp.lib_class_type_id
    create_help_window
    create_class_status_window
    create_class_name_window
    create_class_type_window
    create_result_popup_window
    
    class_type_name = ["職業", "種族"].at(@change_class_type_id)
    @help_window.text = "#{class_type_name}情報（収集率には含みません）"
    @class_status_window.show.activate
    @class_status_window.actor_id = @change_class_actor_id
    @class_type_window.show.activate
    @class_type_window.class_type_id = @change_class_type_id 
    @class_type_window.refresh
    @class_type_window.select(0)
    @class_name_window.show.activate
    @class_name_window.class_type_id = @change_class_type_id
    @class_name_window.actor_id = @change_class_actor_id
    @class_name_window.refresh
    @class_name_window.select(0)
  end
  #--------------------------------------------------------------------------
  # ● クラスステータスウィンドウの作成
  #--------------------------------------------------------------------------
  def create_class_status_window
    @class_status_window = Foo::JobChange::LibWindow_ClassStatus.new
  end
  #--------------------------------------------------------------------------
  # ● クラス選択ウィンドウの作成
  #--------------------------------------------------------------------------
  def create_class_name_window
    @class_name_window = Foo::JobChange::LibWindow_ClassName.new(@class_status_window)
    @class_name_window.set_handler(:cancel, method(:return_scene))
  end
  #--------------------------------------------------------------------------
  # ● クラスタイプ選択ウィンドウの作成
  #--------------------------------------------------------------------------
  def create_class_type_window
    @class_type_window = Foo::JobChange::Window_ClassType.new(@class_name_window)
  end
end
