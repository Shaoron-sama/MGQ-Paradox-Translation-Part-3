=begin
=アビリティ編集画面

KUREメモライズシステム及びパッシブスキルを踏襲し
もんむすRPGの仕様に即したアビリティシステムを提供します

==更新履歴
  Date     Version Author Comment
==15/09/03 2.0.2   トリス 統合J～U K
==17/05/16 2.0.4   トリス 統合V～W W
==17/10/27 2.2.0   ひまわり　バグ修正

=end

#==============================================================================
# ■ NWConst::Ability
#==============================================================================
module NWConst::Ability
  ABILITY_SKILL_TYPE = [1, 2, 3, 4, 5]
  AP_NAME = "AP"
  REMOVE_SE = RPG::SE.new("Equip1")  
end

# 重複防止用ネームスペース
module Foo; module Ability; end; end


#==============================================================================
# ■ Game_Actor
#==============================================================================
class Game_Actor < Game_Battler
  attr_accessor   :equip_abilities
  #--------------------------------------------------------------------------
  # ○ スキルの初期化
  #--------------------------------------------------------------------------
  alias nw_ability_init_skills init_skills
  def init_skills
    @abilities = {}
    @equip_abilities = {}
    NWConst::Ability::ABILITY_SKILL_TYPE.each{|stype_id|
      @abilities[stype_id] = []
      @equip_abilities[stype_id] = []
    }
    nw_ability_init_skills
  end
  #--------------------------------------------------------------------------
  # ○ スキルオブジェクトの配列取得
  #--------------------------------------------------------------------------
  alias nw_abilities skills
  def skills
    nw_abilities + all_abilities.collect{|id| $data_skills[id]}
  end
	
  #--------------------------------------------------------------------------
  # ○ スキルを覚える
  #--------------------------------------------------------------------------
  alias nw_ability_learn_skill learn_skill
  def learn_skill(skill_id)
    # スキル・アビリティ問わず習得不可設定を適用します
    return unless skill_learnable?($data_skills[skill_id])
    
    if $data_skills[skill_id].ability?
			stype_id = $data_skills[skill_id].stype_id
      @abilities[stype_id] |= [skill_id] 
      @abilities[stype_id].sort!
    else
      nw_ability_learn_skill(skill_id)
    end
  end
  #--------------------------------------------------------------------------
  # ○ スキルを忘れる
  #--------------------------------------------------------------------------
  alias nw_ability_forget_skill forget_skill
  def forget_skill(skill_id)
    stype_id = $data_skills[skill_id].stype_id
    if NWConst::Ability::ABILITY_SKILL_TYPE.include?(stype_id)
      @abilities[stype_id].delete(skill_id)
      @equip_abilities[stype_id].delete(skill_id)
    else
      nw_ability_forget_skill(skill_id)
    end
  end
  #--------------------------------------------------------------------------
  # ○ スキルの習得済み判定
  #--------------------------------------------------------------------------
  alias nw_ability_skill_learn? skill_learn?
  def skill_learn?(skill)
    nw_ability_skill_learn?(skill) || (skill.is_skill? && all_equip_abilities.include?(skill.id))
  end
  #--------------------------------------------------------------------------
  # ● 装着アビリティの特徴オブジェクト取得
  #--------------------------------------------------------------------------  
  def ability_feature_objects
    all_equip_abilities.collect{|ability_id|
      $data_skills[ability_id].passive_armors.collect{|armor_id|
        $data_armors[armor_id]
      }
    }.flatten
  end
  #--------------------------------------------------------------------------
  # ● 全アビリティIDの配列取得
  #--------------------------------------------------------------------------  
  def all_abilities
    @abilities.values.flatten
  end
  #--------------------------------------------------------------------------
  # ● 全装着アビリティIDの配列取得
  #--------------------------------------------------------------------------  
  def all_equip_abilities
    @equip_abilities.values.flatten
  end
	
  #--------------------------------------------------------------------------
  # ● 使用AP取得
  #--------------------------------------------------------------------------  
  def ap(stype_id)
    @equip_abilities[stype_id].inject(0){|sum, id| sum += $data_skills[id].memorize_cost}
  end
  #--------------------------------------------------------------------------
  # ● 現在APレートの取得  
  #--------------------------------------------------------------------------    
  def ap_rate(stype_id)
    max_ap(stype_id) == 0 ? 0.0 : ap(stype_id) / max_ap(stype_id).to_f
  end
  #--------------------------------------------------------------------------
  # ● 装着アビリティを外す（アビリティタイプ, インデックス指定）
  #--------------------------------------------------------------------------  
  def remove_ability_index(stype_id, index)
    @equip_abilities[stype_id].delete_at(index)
    refresh
  end
  #--------------------------------------------------------------------------
  # ● 装着アビリティを外す（アビリティタイプ指定）
  #--------------------------------------------------------------------------  
  def remove_ability_type(stype_id)
    @equip_abilities[stype_id].clear
    refresh
  end
  #--------------------------------------------------------------------------
  # ● 装着アビリティを全て外す
  #--------------------------------------------------------------------------  
  def remove_ability_all
    @equip_abilities.each_value{|value| value.clear}
    refresh
  end
end

#==============================================================================
# ■ Foo::Ability::Window_StandAbility
#==============================================================================
class Foo::Ability::Window_StandAbility < Window_Command
  #--------------------------------------------------------------------------
  # ● 公開インスタンス変数
  #-------------------------------------------------------------------------
  attr_writer   :actor
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize
    @stype_id = 0
    @select_equip_id = 0
    @data = []
    super(Graphics.width / 2, 216)
    deactivate
    unselect
  end
  #--------------------------------------------------------------------------
  # ● ウィンドウ幅の取得
  #--------------------------------------------------------------------------
  def window_width
    Graphics.width / 2
  end
  #--------------------------------------------------------------------------
  # ● ウィンドウ高さの取得
  #--------------------------------------------------------------------------
  def window_height
    Graphics.height - 216 - fitting_height(1)
  end
  #--------------------------------------------------------------------------
  # ● 選択可能なアビリティが存在しない？
  #--------------------------------------------------------------------------
  def empty?
    @list.empty?
  end  
  #--------------------------------------------------------------------------
  # ● 選択アビリティIDの取得
  #--------------------------------------------------------------------------
  def ability_id
    current_data[:name]
  end
  #--------------------------------------------------------------------------
  # ● スキルタイプIDの設定
  #--------------------------------------------------------------------------
  def stype_id=(id)
    @stype_id = id
    refresh
  end
  #--------------------------------------------------------------------------
  # ● 選択中の装着アビリティIDの設定
  #--------------------------------------------------------------------------
  def select_equip_id=(id)
    @select_equip_id = id
    refresh
  end
  #--------------------------------------------------------------------------
  # ● コマンドリストの作成
  #--------------------------------------------------------------------------
  def make_command_list
    @data.each do |ability|
      add_command(ability.id, :ok, enable_command?(ability.id), ability.memorize_cost)
    end
  end

  def make_item_list
    @data = []
    return if @stype_id == 0

    @data = @actor.abilities(@stype_id).reject do |stand_id|
      @actor.equip_abilities[@stype_id].include?(stand_id)
    end
    @data.map!{|id| $data_skills[id]}
  end

  def enable_command?(id)
    return false unless $data_skills[id].class_conditions_met?(@actor)

    ap_cost = $data_skills[id].memorize_cost - not_jumble_ability_cost(id)
    ap_cost -= $data_skills[@select_equip_id].memorize_cost if @select_equip_id != 0
    @actor.max_ap(@stype_id) - @actor.ap(@stype_id) >= ap_cost
  end

  def not_jumble_ability_cost(id)
    minus_ap_costs = @actor.equip_abilities[@stype_id].map do |equip_id|
      if $data_skills[id].not_jumble_memorize.include?(equip_id) && equip_id != @select_equip_id
        $data_skills[equip_id].memorize_cost
      else
        0
      end
    end
    minus_ap_costs.inject(0, :+)
  end

  def refresh
    make_item_list
    super
  end

  #--------------------------------------------------------------------------
  # ● 項目の描画
  #--------------------------------------------------------------------------
  def draw_item(index)
    rect = item_rect_for_text(index)
    ability = $data_skills[command_name(index)]
    draw_item_name(ability, rect.x, rect.y, command_enabled?(index))
    change_color(system_color)
    draw_text(rect, @list[index][:ext].to_s, 2)
  end
  #--------------------------------------------------------------------------
  # ● ヘルプウィンドウの更新
  #--------------------------------------------------------------------------
  def update_help
    super
    @help_window.set_item($data_skills[command_name(self.index)]) unless empty?
  end
end

#==============================================================================
# ■ Foo::Ability::Window_EquipAbility
#==============================================================================
class Foo::Ability::Window_EquipAbility < Window_Command
  #--------------------------------------------------------------------------
  # ● 公開インスタンス変数
  #-------------------------------------------------------------------------
  attr_writer   :actor
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(stand_ability)
    @stand_ability = stand_ability
    @stype_id = 0
    super(0, 216)
    deactivate
    unselect
  end
  #--------------------------------------------------------------------------
  # ● ウィンドウ幅の取得
  #--------------------------------------------------------------------------
  def window_width
    Graphics.width / 2
  end
  #--------------------------------------------------------------------------
  # ● ウィンドウ高さの取得
  #--------------------------------------------------------------------------
  def window_height
    Graphics.height - 216 - fitting_height(1)
  end
  #--------------------------------------------------------------------------
  # ● スキルタイプIDの設定
  #--------------------------------------------------------------------------
  def stype_id=(id)
    @stype_id = id
    refresh
  end
  #--------------------------------------------------------------------------
  # ● 項目の選択（オーバーライド）
  #--------------------------------------------------------------------------
  def select(index)
    super
    @stand_ability.select_equip_id = command_name(index) unless @list.empty?
  end
  #--------------------------------------------------------------------------
  # ● コマンドリストの作成
  #--------------------------------------------------------------------------
  def make_command_list
    return if @stype_id == 0
    @actor.equip_abilities[@stype_id].each{|equip_id|
      ap_cost = $data_skills[equip_id].memorize_cost
      add_command(equip_id, :ok, true, ap_cost)
    }
    add_command(0, :ok)
  end
  #--------------------------------------------------------------------------
  # ● 項目の描画
  #--------------------------------------------------------------------------
  def draw_item(index)
#~     prefix_text = sprintf("%2d.", index + 1)
    prefix_text = "E:"
    rect = item_rect_for_text(index)
    change_color(normal_color)
    draw_text(rect, prefix_text)   
    return if command_name(index) == 0
    
    rect.x += text_size(prefix_text).width
    rect.width -= text_size(prefix_text).width
    ability = $data_skills[command_name(index)]
    draw_item_name(ability, rect.x, rect.y, command_enabled?(index))
    change_color(system_color)
    draw_text(rect, @list[index][:ext].to_s, 2)      
  end
  #--------------------------------------------------------------------------
  # ● 決定やキャンセルなどのハンドリング処理
  #--------------------------------------------------------------------------
  def process_handling
    return unless open? && active
    return process_ok       if ok_enabled?        && Input.trigger?(:C)
    return process_cancel   if cancel_enabled?    && Input.trigger?(:B)
    return process_extra    if handle?(:extra)    && Input.trigger?(:A)
    return process_pagedown if handle?(:pagedown) && Input.trigger?(:R)
    return process_pageup   if handle?(:pageup)   && Input.trigger?(:L)
  end
  #--------------------------------------------------------------------------
  # ● サブボタンが押されたときの処理
  #--------------------------------------------------------------------------
  def process_extra
    Input.update
    NWConst::Ability::REMOVE_SE.play
    call_handler(:extra)
  end
  #--------------------------------------------------------------------------
  # ● ヘルプウィンドウの更新
  #--------------------------------------------------------------------------
  def update_help
    super
    @help_window.set_item($data_skills[command_name(self.index)])
  end
  #--------------------------------------------------------------------------
  # ● リフレッシュ
  #--------------------------------------------------------------------------
  def refresh
    super
    select([index, item_max - 1].min)
  end
end

#==============================================================================
# ■ Foo::Ability::Window_AbilityType
#==============================================================================
class Foo::Ability::Window_AbilityType < Window_Selectable
  #--------------------------------------------------------------------------
  # ● 公開インスタンス変数
  #-------------------------------------------------------------------------
  attr_writer   :actor
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #-------------------------------------------------------------------------
  def initialize(equip_ability, stand_ability)
    @equip_ability = equip_ability
    @stand_ability = stand_ability
    super(0, 72, Graphics.width, fitting_height(5))
    activate
    select(0)
  end
  #--------------------------------------------------------------------------
  # ● 項目数の取得
  #--------------------------------------------------------------------------
  def item_max
    NWConst::Ability::ABILITY_SKILL_TYPE.size
  end
  #--------------------------------------------------------------------------
  # ● 項目の幅を取得
  #--------------------------------------------------------------------------
  def item_width
    320
  end
  #--------------------------------------------------------------------------
  # ● 選択中のスキルタイプIDを取得
  #--------------------------------------------------------------------------
  def stype_id
    return 0 if self.index == -1
    return NWConst::Ability::ABILITY_SKILL_TYPE[self.index]
  end  
  #--------------------------------------------------------------------------
  # ● 項目を描画する矩形の取得
  #--------------------------------------------------------------------------
  def item_rect(index)
    rect = Rect.new
    rect.width = item_width
    rect.height = item_height
    rect.x = contents.width - item_width
    rect.y = index * item_height
    rect
  end
  #--------------------------------------------------------------------------
  # ● アクターステータスの描画
  #--------------------------------------------------------------------------  
  def draw_actor_status
    x = 0
    y = line_height
    draw_actor_face(@actor, x, y)    
    x  = 100
    y += line_height / 2
    draw_actor_name(@actor, x, y)

#~     rect = Rect.new(x, y, 120, line_height)
    rect = Rect.new(x, y, 150, line_height)
    reset_font_settings
    last_font = contents.font.size
    contents.font.size = 20
    draw_actor_level(@actor, rect.x + 150, rect.y, :base)
    rect.x = 100; rect.y += line_height
    change_color(tp_gauge_color2)
    draw_text(rect, @actor.class.name)
    draw_actor_level(@actor, rect.x + 150, rect.y, :class)
    rect.y += line_height
    change_color(mp_gauge_color2)
    draw_text(rect, @actor.tribe.name)
    draw_actor_level(@actor, rect.x + 150, rect.y, :tribe)
    contents.font.size = last_font
  end
  #--------------------------------------------------------------------------
  # ● 項目の描画
  #--------------------------------------------------------------------------
  def draw_item(index)
    stype_id = @actor.abilities.keys[index]
    ability_name = $data_system.skill_types[stype_id]
    reset_font_settings
    draw_text(item_rect(index), ability_name)
    #
    x = item_rect(index).x + 190
    y = item_rect(index).y
    width = 120
    draw_gauge(x, y, width, @actor.ap_rate(stype_id), tp_gauge_color1, tp_gauge_color2)
    change_color(system_color)
    draw_text(x, y, width, line_height, NWConst::Ability::AP_NAME)
    text = sprintf("%2d/%2d", @actor.ap(stype_id), @actor.max_ap(stype_id))
    change_color(normal_color)
    draw_text(item_rect(index), text, 2)
  end
  #--------------------------------------------------------------------------
  # ● 項目の選択（オーバーライド）
  #--------------------------------------------------------------------------
  def select(index)
    super
    @equip_ability.stype_id = stype_id if @equip_ability
    @stand_ability.stype_id = stype_id if @stand_ability
  end
  #--------------------------------------------------------------------------
  # ● リフレッシュ
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    draw_actor_status
    draw_all_items
  end
  #--------------------------------------------------------------------------
  # ● 決定やキャンセルなどのハンドリング処理
  #--------------------------------------------------------------------------
  def process_handling
    return unless open? && active
    return process_ok       if ok_enabled?        && Input.trigger?(:C)
    return process_cancel   if cancel_enabled?    && Input.trigger?(:B)
    return process_extra    if handle?(:extra)    && Input.trigger?(:A)
    return process_pagedown if handle?(:pagedown) && Input.trigger?(:R)
    return process_pageup   if handle?(:pageup)   && Input.trigger?(:L)
  end
  #--------------------------------------------------------------------------
  # ● サブボタンが押されたときの処理
  #--------------------------------------------------------------------------
  def process_extra
    Input.update
    NWConst::Ability::REMOVE_SE.play
    call_handler(:extra)
  end
end

#==============================================================================
# ■ Scene_Ability
#==============================================================================
class Scene_Ability < Scene_MenuBase
  #--------------------------------------------------------------------------
  # ● 開始処理
  #--------------------------------------------------------------------------
  def start  
    super
    create_help_window
    create_stand_ability_window
    create_equip_ability_window
    create_ability_type_window
    create_key_help_window
  end
  #--------------------------------------------------------------------------
  # ● 待機アビリティウィンドウの生成
  #--------------------------------------------------------------------------
  def create_stand_ability_window
    @stand_ability_window = Foo::Ability::Window_StandAbility.new
    @stand_ability_window.set_handler(:ok, method(:process_stand_ability_ok))
    @stand_ability_window.set_handler(:cancel, method(:process_stand_ability_cancel))
    @stand_ability_window.actor = @actor
    @stand_ability_window.help_window = @help_window
  end
  #--------------------------------------------------------------------------
  # ● 待機アビリティの決定
  #--------------------------------------------------------------------------
  def process_stand_ability_ok
    stype_id   = @ability_type_window.stype_id
    index      = @equip_ability_window.index
    ability_id = @stand_ability_window.ability_id
    @actor.change_ability(index, ability_id)
    @stand_ability_window.unselect
    @equip_ability_window.activate
    @ability_type_window.refresh
    @equip_ability_window.refresh
    @stand_ability_window.refresh
    @equip_ability_window.update_help
  end
  #--------------------------------------------------------------------------
  # ● 待機アビリティのキャンセル
  #--------------------------------------------------------------------------
  def process_stand_ability_cancel
    @stand_ability_window.unselect
    @equip_ability_window.activate
    @equip_ability_window.update_help
  end
  #--------------------------------------------------------------------------
  # ● 装着アビリティウィンドウの生成
  #--------------------------------------------------------------------------
  def create_equip_ability_window
    @equip_ability_window = Foo::Ability::Window_EquipAbility.new(@stand_ability_window)
    @equip_ability_window.set_handler(:ok, method(:process_equip_ability_ok))
    @equip_ability_window.set_handler(:cancel, method(:process_equip_ability_cancel))
    @equip_ability_window.set_handler(:extra, method(:process_equip_ability_remove))
    @equip_ability_window.actor = @actor
    @equip_ability_window.help_window = @help_window
  end
  #--------------------------------------------------------------------------
  # ● 装着アビリティの決定
  #--------------------------------------------------------------------------
  def process_equip_ability_ok
    if @stand_ability_window.empty?
      @equip_ability_window.activate
      return
    end
    @stand_ability_window.activate
    @stand_ability_window.select(0)
    @stand_ability_window.update_help
  end
  #--------------------------------------------------------------------------
  # ● 装着アビリティのキャンセル
  #--------------------------------------------------------------------------
  def process_equip_ability_cancel
    @equip_ability_window.unselect
    @stand_ability_window.select_equip_id = 0
    @stand_ability_window.select(0) unless @stand_ability_window.empty?
    @stand_ability_window.unselect
    @ability_type_window.activate
    @ability_type_window.update_help
  end
  #--------------------------------------------------------------------------
  # ● 装着アビリティの削除
  #--------------------------------------------------------------------------
  def process_equip_ability_remove
    @actor.remove_ability_index(@ability_type_window.stype_id, @equip_ability_window.index)
    @ability_type_window.refresh
    @equip_ability_window.refresh
    @stand_ability_window.refresh    
    @equip_ability_window.update_help
  end
  #--------------------------------------------------------------------------
  # ● アビリティタイプウィンドウの生成
  #--------------------------------------------------------------------------
  def create_ability_type_window
    @ability_type_window = 
      Foo::Ability::Window_AbilityType.new(@equip_ability_window, @stand_ability_window)
    @ability_type_window.set_handler(:ok,   method(:process_ability_type_ok))
    @ability_type_window.set_handler(:cancel,   method(:return_scene))
    @ability_type_window.set_handler(:extra,   method(:process_ability_type_remove))
    @ability_type_window.set_handler(:pagedown, method(:next_actor))
    @ability_type_window.set_handler(:pageup,   method(:prev_actor))
    @ability_type_window.actor = @actor
    @ability_type_window.help_window = @help_window
    @ability_type_window.refresh
    @ability_type_window.update_help
  end
  #--------------------------------------------------------------------------
  # ● アビリティタイプの決定
  #--------------------------------------------------------------------------
  def process_ability_type_ok
    @ability_type_window.deactivate
    @equip_ability_window.activate
    @equip_ability_window.select(0)
    @equip_ability_window.update_help
  end
  #--------------------------------------------------------------------------
  # ● アビリティタイプの削除
  #--------------------------------------------------------------------------
  def process_ability_type_remove
    @actor.remove_ability_type(@ability_type_window.stype_id)
    @ability_type_window.refresh
    @equip_ability_window.refresh
    @stand_ability_window.refresh
  end
  #--------------------------------------------------------------------------
  # ● 操作ヘルプウィンドウの生成
  #--------------------------------------------------------------------------
  def create_key_help_window
    @key_help_window = Window_Help.new(1)
    @key_help_window.y = Graphics.height - @key_help_window.fitting_height(1)
    @key_help_window.set_text(Help.ability_key)
  end
  #--------------------------------------------------------------------------
  # ● アクターの切り替え
  #--------------------------------------------------------------------------
  def on_actor_change
    @equip_ability_window.actor = @actor
    @stand_ability_window.actor = @actor
    @ability_type_window.actor = @actor
    @ability_type_window.refresh
    @ability_type_window.activate
    @equip_ability_window.unselect
    @stand_ability_window.unselect
    @ability_type_window.select(0)
    @equip_ability_window.select(0)
    @ability_type_window.update_help
  end
  #--------------------------------------------------------------------------
  # ● 呼び出し元のシーンへ戻る
  #--------------------------------------------------------------------------
  def return_scene
    $game_party.all_members.each{|member| member.refresh}
    super
  end
end
