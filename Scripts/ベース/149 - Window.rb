class Window
  module NoFrame
    def initialize(x, y, width, height)
      super(x, y, width, height)
      self.arrows_visible = false
      self.opacity = 0
      create_back_bitmap
      create_back_sprite
    end

    def create_back_bitmap
      @back_bitmap = Bitmap.new(width, height)
    end

    def draw_background
      @back_bitmap.clear
      @back_bitmap.fill_rect(back_rect, back_color)
    end

    def create_back_sprite
      @back_sprite = Sprite.new
      @back_sprite.viewport = viewport
      @back_sprite.bitmap = @back_bitmap
      @back_sprite.opacity = back_sprite_opacity
      @back_sprite.x = x
      @back_sprite.y = y
      @back_sprite.z = z - 1
    end

    def back_rect
      Rect.new(0, standard_padding, width, contents_height)
    end

    def back_color
      Color.new(0, 0, 0, 255)
    end

    def back_sprite_opacity
      64
    end

    def dispose_back_bitmap
      @back_bitmap.dispose
    end

    def dispose_back_sprite
      @back_sprite.dispose
    end

    def dispose
      super
      dispose_back_bitmap
      dispose_back_sprite
    end

    def visible=(other)
      super(other)
      @back_sprite.visible = other
    end

    def viewport=(viewport)
      super(viewport)
      @back_sprite.viewport = viewport
    end

    def opacity=(opacity)
      return super(opacity) unless @back_sprite

      @back_sprite.opacity = opacity
    end

    def opacity
      @back_sprite.opacity
    end

    def y=(other)
      super(other)
      @back_sprite.y = y
    end

    def x=(other)
      super(other)
      @back_sprite.x = x
    end

    def z=(other)
      super(other)
      @back_sprite.z = other - 1
    end

    def width=(other)
      super(other)
      @back_sprite.width = other
    end

    def height=(other)
      super(other)
      @back_sprite.height = other
    end
  end
end

class Window_TitleSelectable < Window_Base
  def initialize(window)
    @contents_window = window
    @title = []
    @title_window = Window_Base.new(0, 0, 1, 1)
    @title_window.define_singleton_method(:text_auto_reduce?) do
      true
    end
    super(0, 0, 1, 1)
    w = self
    @contents_window.define_singleton_method(:refresh) do
      super()
      w.refresh(false)
    end
    @contents_window.define_singleton_method(:window_width) do
      [super(), w.title_width].max
    end

    @contents_window.define_singleton_method(:window_height) do
      [super(), Graphics.height - (w.title_height + 6)].min
    end
    [@title_window, @contents_window].each do |w|
      w.opacity = 0
      w.deactivate
    end

    self.arrows_visible = false
    self.visible = false
  end

  def refresh(ref_inner = true)
    @contents_window.refresh if ref_inner
    create_contents
    draw_title
  end

  def draw_title
    y = 0
    @title.each do |line|
      rect = text_size_ex(format(line, @name))
      x = if rect.width > contents_width
            0
          else
            (contents_width - rect.width) / 2
          end
      @title_window.draw_text_ex(x, y, format(line, @name), contents_width)
      y += rect.height
    end
  end

  def window_height
    [@contents_window.height + title_height + 6, Graphics.height].min
  end

  def window_width
    [title_width, @contents_window.width].max.clamp(0, Graphics.width)
  end

  def title_width
    (title_rect.width + standard_padding * 2 + 20).clamp(0, Graphics.width)
  end

  def create_contents
    move_x = (Graphics.width / 2) - (window_width / 2)
    move_y = (Graphics.height / 2) - (window_height / 2)
    move(move_x, move_y, window_width, window_height)
    @title_window.move(move_x, move_y, window_width, @title_window.fitting_height(@title ? @title.size : 1))
    @title_window.create_contents
    self.contents ||= Bitmap.new(1, 1)
  end

  def move(x, y, width, height)
    self.x = x
    self.y = y
    self.width = width
    self.height = height
  end

  def title_height
    title_rect.height
  end

  def set_title(title)
    @title = title.split("\\n")
    refresh
  end

  def title_rect
    h = @title.map do |line|
      @title_window.text_size_ex(format(line, @name))
    end
    result = h.each_with_object(Rect.new) do |r, obj|
      obj.width = [obj.width, r.width].max
      obj.height += r.height
    end
  end

  def set_name(name)
    @name = name
    refresh
  end

  def method_missing(name, *args)
    @contents_window.send(name, *args)
  end

  def respond_to_missing?(name, all)
    @contents_window.respond_to?(name, all)
  end

  def dispose
    super
    @contents_window.dispose
    @title_window.dispose
  end

  def active=(other)
    super
    @contents_window.active = other
    @title_window.active = other
  end

  def visible=(other)
    super
    @contents_window.visible = other
    @title_window.visible = other
  end

  def viewport=(viewport)
    super
    @contents_window.viewport = viewport
    @title_window.viewport = viewport
  end

  def opacity=(opacity)
    super
    @contents_window.opacity = opacity
    @title_window.opacity = opacity
  end

  def y=(other)
    super
    @contents_window.y = other + title_height + 6
    @title_window.y = other
  end

  def x=(other)
    super
    @contents_window.x = other
    @title_window.x = other
  end

  def z=(other)
    super
    @contents_window.z = other + 1
    @title_window.z = other + 1
  end

  def width=(other)
    super(other)
    @contents_window.width = other
    @title_window.width = other
  end

  def height=(other)
    super
    @contents_window.height = other - title_height - 6
    @title_window.height = title_height
  end

  def update
    super
    @contents_window.update
    @title_window.update
    self.active = @contents_window.active if active != @contents_window.active
    self.visible = @contents_window.visible if visible != @contents_window.visible
  end
end

class Window_PopupConfirm < Window_TitleSelectable
  def initialize(window = nil)
    super(window || Window_PopupConfirmInner.new)
    self.z = 200
  end
end

class Window_PopupConfirmInner < Window_Command
  def initialize
    super(0, 0)
  end

  def make_command_list
    add_command("はい", :ok)
    add_command("いいえ", :cancel)
  end

  def item_width
    100
  end

  def process_ok
    return process_cancel if current_symbol == :cancel && handle?(:cancel)

    Input.update
    deactivate
    call_ok_handler
  end

  def create_contents
    self.width = window_width
    self.height = window_height
    super
  end

  def alignment
    1
  end

  def item_rect(index)
    rect = Rect.new
    rect.width = item_width
    rect.height = item_height
    rect.x = (contents_width - item_width) / 2
    rect.y = (index / col_max * item_height)
    rect
  end
end

class Window_SelectActor < Window_PopupConfirmInner
  attr_reader :item

  def initialize
    @actors = []
    super
  end

  def item=(item)
    @item = item
    @name = item.window_name
  end

  def actors=(actors)
    @actors = actors
    refresh
  end

  def make_command_list
    @actors.each do |actor|
      add_command(actor.name, :ok, true, actor)
    end
  end

  def window_width
    [(item_width + standard_padding * 2 + 20), super].max
  end

  def item_width
    return 0 if @list.empty?
    text_size(@list.max_by{|h|h[:name].width}[:name]).width + 20
  end
end
class Window_SelectSynthesizeMaterialActor < Window_SelectActor
  def make_command_list
    return unless @item
    @actors.each do |actor, slot_id|
      add_command(actor.name, :ok, true, [actor, slot_id])
    end
  end
  
end
class Window_SelectActorSlotEquip < Window_SelectActor
  attr_accessor :prioritize_list

  def initialize
    super
    @prioritize_list = []
  end

  def make_command_list
    return unless @item
    add_command("装備しない", :cancel, true)
    @actors.each do |actor|
      slots = actor.slot_list(@item.etype_id).select { |id| actor.equip_change_ok?(id) }
      slots.each do |slot_id|
        cmd = slots.size == 1 ? actor.name : "#{actor.name}(#{actor.slot_name(slot_id)})"
        add_command(cmd, :ok, true, [actor, slot_id])
      end
    end
    i = 0
    @list.sort_by!{|h| [prioritize_list.include?(h[:ext]) ? 0 : 1, i += 1]}
  end

  def draw_item(index)
    change_color(item_color(index), command_enabled?(index))
    draw_text(item_rect_for_text(index), command_name(index), alignment)
  end

  def item_color(index)
    prioritize_list.include?(command_ext(index)) ? crisis_color : normal_color
  end

  def process_cancel
    Input.update
    deactivate
    call_cancel_handler
  end
end

class Window_Equip_Stone_Help_Base < Window_Base
  attr_accessor :item
  MSG = "秘石を変更したいソケットを選択してください"

  def initialize
    @index = 0
    super(0, 0, Graphics.width, fitting_height(2))
  end

  def refresh
    contents.clear
    draw_item if item
  end
end

class Window_Equip_Stone_Help_Actor < Window_Equip_Stone_Help_Base
  attr_accessor :socket_num

  def draw_item
    change_color(normal_color)
    rect = Rect.new(0, 0, contents_width, line_height)

    draw_text(rect, MSG)
    draw_text(rect, item.name, 2)
    rect.y += line_height
    draw_text(rect, "総ソケット数:#{socket_num}", 2) if socket_num
  end
end

class Window_Equip_Stone_Help_Item < Window_Equip_Stone_Help_Base
  def draw_item
    change_color(normal_color)
    rect = Rect.new(0, 0, contents_width, line_height)

    draw_text(rect, MSG)
    w = [contents_width, text_size_ex(item.name).width + 30].min
    x = contents_width - w
    draw_item_name(item, x, line_height, true, w)
  end
end

class Window_PartyRecover < Window_Base
  def initialize
    super(0, 0, 160, fitting_height(2))
    refresh
  end

  def refresh
    contents.clear
    $game_system.party_recover.refresh
    change_color(normal_color)
    draw_text(0, 0, contents_width, line_height, "#{Vocab.key_a}: 回復")
    if skill.nil?
      change_color(system_color)
      draw_text(24, line_height, contents_width, line_height, "未設定")
    else
      draw_item_name(skill, 0, line_height, party_recover_enable?, contents_width)
    end
  end

  def recover
    unless party_recover_enable?
      Sound.play_buzzer
      return
    end

    Sound.play_use_skill
    user.use_item(skill)
    targets = if skill.for_all?
                $game_party.members
              else
                [$game_party.members.find do |m|
                   m.hp_rate < 1
                 end]
              end
    targets.each do |target|
      skill.repeats.times { target.item_apply(user, skill) }
    end
    user.item_one_use_apply(skill, targets, self)
    SceneManager.goto(Scene_Map) if $game_temp.common_event_reserved?
  end

  private

  def party_recover_enable?
    return false if skill.nil? || user.nil?
    return false unless $game_party.members.any? { |m| m.hp_rate < 1 }

    user.added_skill_types.include_any?(skill.stypes) && user.usable?(skill)
  end

  def skill
    $game_system.party_recover.skill
  end

  def user
    $game_system.party_recover.user
  end
end

class Window_PopUpResult < Window_Base
  include Window::NoFrame
  F = ->(t) { -2 * t**3 + 3 * t**2 }
  attr_accessor :pos
  attr_reader :type
  def initialize(text, type, pos = 0)
    super(-window_width, -20, window_width, window_height)
    @text = text
    @type = type
    @count = 0
    @pos = pos
    refresh
  end

  def window_width
    160
  end

  def window_height
    fitting_height(1)
  end

  def refresh
    draw_background
    create_contents
    draw_text(0, 0, contents_width, line_height, @text)
  end

  def standard_padding
    1
  end

  def update
    @pos += 1
    self.x = -window_width + window_width * F.call(@pos.clamp(0, 8) / 8.0)
  end
end

class PopupResults
  module Type
    ELEMENT_RATE = 1
    STATE_BOOST = 2
    CATEGORY_BOOST = 3
  end

  ELEMENTS = [53, 50, 49, 48, 47, 46, 45, 44, 43, 52, 51, 41, 40, 36, 35, 10, 9, 8, 7, 6, 5, 4, 3, 2]
  def initialize
    @windows = []
  end

  def push(message, type)
    w = @windows.find { |w| w.type == type }
    return if w

    @windows.push(Window_PopUpResult.new(message, type, -@windows.count { |w| w.pos == 0 } * 2))
    refresh
  end

  def push_hp_damage_elements(elements)
    id = elements.select { |e| ELEMENTS.include?(e) }.min_by { |e| ELEMENTS.index(e) }
    return unless id

    push("#{$data_system.elements[id]}属性弱点", Type::ELEMENT_RATE)
  end

  def push_state_boost(states)
    states.each do |state|
      text = $data_states[state].popup_boost_name
      push("#{text}", [Type::STATE_BOOST, state]) if text
    end
  end

  def push_ex_category_boost(categories)
    categories.each do |category|
      text = Vocab.ex_category(category)
      push("#{text}特攻", [Type::CATEGORY_BOOST, category]) if text
    end
  end

  def update
    @windows.each(&:update)
  end

  def refresh
    @windows.each_with_index do |w, i|
      w.y = i * w.height + 5
    end
  end

  def clear
    @windows.each(&:dispose)
    @windows.clear
  end
end

class Window_Socket < Window_Base
  class << self
    attr_accessor :empty_text
  end
  attr_reader   :selected
  attr_accessor :equip
  attr_accessor :stone
  attr_accessor :socket_id
  attr_accessor :index
  attr_accessor :max_index

  def selected=(selected)
    if @selected != selected
      @selected = selected
      update_cursor
    end
  end

  def refresh
    contents.clear
    draw_stone if stone
  end

  def update_cursor
    if @selected
      cursor_rect.set(0, 0, cursor_width, line_height)
    else
      cursor_rect.empty
    end
  end

  def cursor_width
    256
  end

  def draw_stone
    if stone == :empty
      unless self.class.empty_text
        r = text_size("－")
        c = cursor_width / r.width
        self.class.empty_text = "－" * c
      end
      draw_text(0, 0, contents_width, line_height, self.class.empty_text)
    else
      draw_item_name(stone, 0, 0, true, 256)
      draw_text_ex(0, line_height + line_height / 4, stone.description.gsub(/^【秘石】/i, ""))
    end
    if equip
      change_color(system_color)
      change_color(normal_color)
      draw_item_name(equip, 380, 0, true, contents_width - 410)
    end
    change_color(normal_color)
    draw_text(0, contents_height - line_height, contents_width, line_height, "#{index + 1}/#{max_index}", 2) if max_index
  end
end
class Window_Enchant_Stone < Window_Base
  attr_accessor :stone

  def initialize(x, y, width, height)
    super(x, y, width, height)
    hide
  end

  def refresh
    contents.clear
    draw_stone if stone
  end

  def draw_stone
    rect = Rect.new(0, 0, contents.width, line_height)
    draw_text(rect, "E:")
    rect.x += 50
    if stone == :empty
      draw_text(rect, "－－－－－－")
    else
      draw_item_name(stone, rect.x, rect.y)
      rect.y += line_height * 3 / 2
      draw_text_ex(rect.x, rect.y, stone.description.gsub(/^【秘石】/i, ""))
    end
  end
end

#==============================================================================
# ■ Window_Enchant_Stones
#==============================================================================
class Window_Enchant_Stones < Window_Base
  include EquipInfoWindow
  attr_accessor :item

  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(x, y, width, height)
    super(x, y, width, height)
    @page_index = 0
    sheight = height + 3 - (height % 3)
    @stone_windows = [
      Window_Enchant_Stone.new(x, y, width, sheight / 3),
      Window_Enchant_Stone.new(x, y + sheight / 3, width, sheight / 3),
      Window_Enchant_Stone.new(x, y + sheight / 3 * 2, width, height - sheight / 3 * 2)
    ]
    hide
  end

  def item=(item)
    @item = item
    @stone_windows.each do |window|
      window.stone = nil
    end
    if item && item.socket?
      item.stones.each.with_index do |stone, index|
        @stone_windows[index].stone = stone || :empty
      end
    end
  end

  def refresh
    @stone_windows.each do |window|
      window.refresh
    end
  end

  def page_max
    !@item.nil? && item.socket? ? 1 : 0
  end

  def show
    @stone_windows.each(&:show)
  end

  def hide
    super
    @stone_windows.each(&:hide)
  end

  def visible
    @stone_windows.any?(&:visible)
  end

  def dispose
    super
    @stone_windows.each(&:dispose)
  end
end
class Window_ActorCommand < Window_Command
  END_CHAIN = "チェーン終了"
  attr_writer :count_window

  #--------------------------------------------------------------------------
  # ● 桁数の取得【オーバーライド】
  #--------------------------------------------------------------------------
  def col_max
    2
  end

  #--------------------------------------------------------------------------
  # ● 横に項目が並ぶときの空白の幅を取得【オーバーライド】
  #--------------------------------------------------------------------------
  def spacing
    4
  end

  #--------------------------------------------------------------------------
  # ● ハンドラの呼び出し
  #--------------------------------------------------------------------------
  def call_handler(symbol)
    case symbol
    when :cancel
    when :skill
      @actor.set_last_stype(current_ext)
    else
      @actor.set_last_stype(symbol)
    end
    @handler[symbol].call if handle?(symbol)
  end

  #--------------------------------------------------------------------------
  # ● 前回の選択位置を復帰
  #--------------------------------------------------------------------------
  def select_last
    stype = @actor.get_last_stype
    select(0)
    return unless stype

    if stype.is_a?(Symbol)
      select_symbol(stype)
    else
      select_ext(stype)
    end
  end

  #--------------------------------------------------------------------------
  # ○ コマンドリストの作成
  #--------------------------------------------------------------------------
  def make_command_list
    return unless @actor

    return make_chain_action_command_list if @actor.chain_input?

    add_attack_command
    if @actor.state?(NWConst::State::TBIND) || @actor.state?(NWConst::State::ETBIND)
      add_resist_bind_command
      add_mercy_command
    else
      add_skill_commands
      add_guard_command
      add_mercy_command
      add_item_command
    end
  end

  #--------------------------------------------------------------------------
  # ○ ウィンドウ幅の取得
  #--------------------------------------------------------------------------
  def window_width
    200
  end

  #--------------------------------------------------------------------------
  # ● 「もがく」をリストに追加
  #--------------------------------------------------------------------------
  def add_resist_bind_command
    add_command($data_skills[NWConst::Skill::BIND_RESIST].name, :bind_resist)
  end

  #--------------------------------------------------------------------------
  # ● 「なすがまま」をリストに追加
  #--------------------------------------------------------------------------
  def add_mercy_command
    add_command($data_skills[NWConst::Skill::MERCY].name, :mercy)
  end

  #--------------------------------------------------------------------------
  # ○ スキルコマンドをリストに追加
  #--------------------------------------------------------------------------
  def add_skill_commands
    @actor.added_skill_types.sort.select do |stype_id|
      stype_usable?(stype_id)
    end.tap do |stypes|
      break @actor.sorted_stypes(stypes)
    end.each  do |stype_id|
      name = $data_system.skill_types[stype_id]
      add_command(name, :skill, true, stype_id)
    end
  end

  #--------------------------------------------------------------------------
  # ● 使用可能なスキルタイプ？（そのタイプのスキルを習得しており非表示でない）
  #--------------------------------------------------------------------------
  def stype_usable?(stype_id)
    return false if $game_system.conf[:bt_stype] && @actor.skill_type_disabled?(stype_id)

    stype_exist_usable_skill?(stype_id)
  end

  def setup(actor)
    @actor = actor
    refresh
    select(0)
    activate
    open
    @count_window.setup(actor) if @count_window
  end

  def stype_exist_usable_skill?(stype_id)
    @actor.skills.any? do |skill|
      skill.stype_id == stype_id && @actor.skill_race_ok?(skill)
    end
  end

  def make_chain_action_command_list
    add_chain_skill_commands
    add_end_command
  end

  def add_end_command
    add_command(END_CHAIN, :end_chain)
  end

  def add_chain_skill_commands
    stypes = @actor.input.stypes
    @actor.sorted_stypes(stypes)
    stypes.each do |stype_id|
      name = $data_system.skill_types[stype_id]
      enable = @actor.added_skill_types.include?(stype_id) && stype_exist_usable_skill?(stype_id)
      add_command(name, :skill, enable, stype_id)
    end
  end

  def draw_item(index)
    stype_id = command_ext(index)
    cflag = @actor.chain_input? ? stype_id && !@actor.next_chain_action_stypes(stype_id).empty? : !@actor.skill_type_id_chain(stype_id).empty?
    color = cflag ? tp_gauge_color2 : normal_color

    change_color(color, command_enabled?(index))
    draw_text(item_rect_for_text(index), command_name(index), alignment)
  end
end

class Window_AutoBattleCommand < Window_Command
  def initialize
    super(0, 0)
    self.openness = 0
    deactivate
  end

  def window_width
    200
  end

  def visible_line_number
    4
  end

  def make_command_list
    add_command(Vocab::AutoBattle::NORMAL, :normal)
    add_command(Vocab::AutoBattle::NOT_MP_SKILL, :not_mp_skill)
    add_command(Vocab::AutoBattle::REPEAT, :repeat)
    add_command(Vocab::AutoBattle::ATTACK_ONLY, :attack_only)
  end
end
class Window_Base
  #--------------------------------------------------------------------------
  # ● 各種文字色の取得
  #--------------------------------------------------------------------------
  # 良性結果
  def good_color
    text_color(29)
  end

  # 悪性結果
  def bad_color
    text_color(18)
  end

  # 特殊結果
  def special_color
    text_color(17)
  end

  # 消費 HP
  def hp_cost_color
    text_color(10)
  end

  # 消費 金額
  def gold_cost_color
    text_color(17)
  end

  def draw_actor_level(actor, x, y, kind)
    change_color(system_color)
    @lv_size ||= text_size(Vocab.level_a)
    draw_text(x, y, width, line_height, Vocab.level_a)
    color = actor.max_level?(kind) ? system_color : normal_color
    change_color(color)
    draw_text(x + @lv_size.width + 3, y, 24, line_height, actor.level[kind], 2)
  end

  def draw_actor_class_level(actor, x, y, class_id, lv_color = nil)
    lv_color ||= system_color
    change_color(lv_color)
    @lv_size ||= text_size(Vocab.level_a)
    draw_text(x, y, width, line_height, Vocab.level_a)
    class_level = actor.level_list[class_id]
    max_lv = $data_classes[class_id].max_lv

    color = !class_level.nil? && max_lv <= class_level ? system_color : normal_color
    change_color(color)
    draw_text(x + @lv_size.width + 3, y, 24, line_height, class_level || "-", 2)
  end

  #--------------------------------------------------------------------------
  # ○ シンプルなステータスの描画
  #--------------------------------------------------------------------------
  def draw_actor_simple_status(actor, x, y, next_exp = false)
    draw_actor_name(actor, x, y, 152)
    last_font_size = contents.font.size
    contents.font.size = 20
    draw_actor_level(actor, x + 150, y + 5, :base)
    change_color(tp_gauge_color2)
    draw_text(x, y + contents.font.size * 1 + 5, 152, line_height, actor.class.name)
    draw_actor_level(actor, x + 150, y + contents.font.size + 5, :class)
    change_color(mp_gauge_color2)
    draw_text(x, y + contents.font.size * 2 + 5, 152, line_height, actor.tribe.name)
    draw_actor_level(actor, x + 150, y + contents.font.size * 2 + 5, :tribe)
    contents.font.size = last_font_size
    draw_actor_hp(actor, x + 200, y + line_height * 0, 140)
    draw_actor_mp(actor, x + 200, y + line_height * 1, 140)
    draw_actor_tp(actor, x + 200, y + line_height * 2, 140)
    if next_exp
      change_color(normal_color)
      last_font_out_color = contents.font.out_color.clone
      contents.font.out_color = Color.new(0, 0, 64, 192)
      base_next_level = actor.max_level?(:base) ? "COMPLETE" : actor.next_level_exp(:base) - actor.base_exp
      class_next_level = actor.max_level?(:class) ? "COMPLETE" : actor.next_level_exp(:class) - actor.class_exp
      tribe_next_level = actor.max_level?(:tribe) ? "COMPLETE" : actor.next_level_exp(:tribe) - actor.tribe_exp
      text = "NEXT #{base_next_level} / #{class_next_level} / #{tribe_next_level}"
      draw_text(x + 3, y + line_height * 3, 360, contents.font.size, text)
      contents.font.out_color = last_font_out_color
    else
      draw_actor_icons(actor, x, y + line_height * 3)
    end
  end

  alias h_window_base_convert_escape_characters convert_escape_characters
  def convert_escape_characters(text)
    result = h_window_base_convert_escape_characters(text)
    result.gsub!(/\eJ\[(\d+)\]/i) { actor_class_name(Regexp.last_match(1).to_i) }
    result.gsub!(/\eK\[(\d+)\]/i) { actor_nickname(Regexp.last_match(1).to_i) }
    result.gsub!(/\eV2\[(\d+)\]/i) { $game_variables[Regexp.last_match(1).to_i].give_unit }
    item_name_proc = proc do |container|
      item = container[Regexp.last_match(1).to_i]
      item ? item.window_name : ""
    end
    result.gsub!(/\eT\[(\d+)\]/i) { item_name_proc.call($data_items) }
    result.gsub!(/\eW\[(\d+)\]/i) { item_name_proc.call($data_weapons) }
    result.gsub!(/\eA\[(\d+)\]/i) { item_name_proc.call($data_armors) }
    result.gsub!(/\eS\[(\d+)\]/i) { item_name_proc.call($data_skills) }
    result.gsub!(/\eCC/i) { "\eC[#{font_color_id}]" }
    result
  end

  def prepare_reduce_draw
    @reduce_bitmap.font = contents.font.clone
  end

  def reduce_draw_text(*args)
    @reduce_bitmap.draw_text(*args)
  end

  def reduce_draw_icon(icon_index, x, y, enabled = true)
    bitmap = Cache.system("Iconset")
    rect = Rect.new(icon_index % 16 * 24, icon_index / 16 * 24, 24, 24)
    @reduce_bitmap.blt(x, y, bitmap, rect, enabled ? 255 : translucent_alpha)
  end

  def process_draw_icon(icon_index, pos)
    args = [icon_index, pos[:x], pos[:y]]
    if @reduce_flag
      args[1] -= pos[:new_x]
      prepare_reduce_draw
      reduce_draw_icon(*args)
      reflect_reduce_contents(pos)
    else
      draw_icon(*args)
    end
    pos[:x] += 24
  end

  def process_normal_character(c, pos)
    text_width = text_size(c).width
    args = [pos[:x], pos[:y], text_width * 2, pos[:height], c]
    if @reduce_flag
      args[0] -= pos[:new_x]
      prepare_reduce_draw
      reduce_draw_text(*args)
      reflect_reduce_contents(pos)
    else
      process_new_line if pos[:width] && pos[:x] + text_width > pos[:width]
      draw_text(pos[:x], pos[:y], text_width * 2, pos[:height], c)
    end
    pos[:x] += text_width
  end

  #--------------------------------------------------------------------------
  # ○ 通貨単位つき数値（所持金など）の描画
  #------------------------------------------------------------------------
  # align指定機能を追加
  #--------------------------------------------------------------------------
  def draw_currency_value(value, unit, x, y, width, align = 2)
    case align
    when 2
      cx = text_size(unit).width
      change_color(normal_color)
      draw_text(x, y, width - cx - 2, line_height, value, 2)
      change_color(system_color)
      draw_text(x, y, width, line_height, unit, 2)
    when 1
      uw = text_size(unit).width
      vw = text_size(value.to_s + unit).width + uw / 2
      x = (width - w) / 2
      change_color(normal_color)
      draw_text(x, y, vw - uw, line_height, value)
      change_color(system_color)
      draw_text(x + vw, y, uw, line_height, unit)
    else
      uw = text_size(unit).width
      vw = text_size(value.to_s).width + uw / 2
      change_color(normal_color)
      draw_text(x, y, vw, line_height, value)
      change_color(system_color)
      draw_text(x + vw, y, uw, line_height, unit)
    end
  end

  def draw_face_hue(face_name, face_index, face_hue, x, y, enabled = true)
    bitmap = Cache.face(face_name, face_hue)
    rect = Rect.new(face_index % 4 * 96, face_index / 4 * 96, 96, 96)
    contents.blt(x, y, bitmap, rect, enabled ? 255 : translucent_alpha)
    bitmap.dispose
  end

  def draw_face(face_name, face_index, x, y, enabled = true)
    draw_face_hue(face_name, face_index, 0, x, y, enabled)
  end

  def font_color_id
    34.times do |id|
      c = contents.font.color
      n = text_color(id)
      return id if c.red == n.red && c.blue == n.blue && c.green == n.green
    end
  end

  def text_size_ex(text)
    reset_font_settings
    text = convert_escape_characters(text)
    pos = { :x => 0, :y => 0, :new_x => 0, :height => calc_line_height(text) }
    process_character_size(text.slice!(0, 1), text, pos) until text.empty?
    Rect.new(0, 0, pos[:x], pos[:height])
  end

  def process_character(c, text, pos)
    setup_reduce_over_line(c, text, pos)
    case c
    when "\n"   # 改行
      process_new_line(text, pos)
    when "\f"   # 改ページ
      process_new_page(text, pos)
    when "\e"   # 制御文字
      process_escape_character(obtain_escape_code(text), text, pos)
    when "\g"
      process_escape_graphics(text, pos)
    else        # 普通の文字
      process_new_line(text, pos) if pos[:width] && pos[:width] < text_size(c).width + pos[:x]
      process_normal_character(c, pos)
    end
  end

  def process_escape_graphics(text, pos)
    reg = /^\["(\S+)",(\d+)\]/
    text.sub!(reg) do
      $game_message.face_name = Regexp.last_match(1)
      $game_message.face_index = Regexp.last_match(2).to_i
      ""
    end
  end

  def process_character_size(c, str, pos)
    case c
    when "\n"   # 改行
      process_new_line(str, pos)
    when "\e"   # 制御文字
      process_escape_character_size(obtain_escape_code(str), str, pos)
    else        # 普通の文字
      pos[:x] += text_size(c).width
    end
  end

  def process_escape_character_size(code, text, pos)
    case code.upcase
    when "C"
      obtain_escape_param(text)
    when "I"
      obtain_escape_param(text)
      pos[:x] += 24
    when "{"
      contents.font.size += 8 if contents.font.size <= 64
    when "}"
      contents.font.size -= 8 if contents.font.size >= 16
    end
  end

  def draw_item_name(item, x, y, enabled = true, width = 236)
    return unless item

    draw_icon(item.icon_index, x, y, enabled)
    change_color(item_color(item), enabled)
    draw_text_autosizing(x + 24, y, width - 24, line_height, item.name)
  end

  #--------------------------------------------------------------------------
  # ● アイテム名の描画
  #     enabled : 有効フラグ。false のとき半透明で描画
  #--------------------------------------------------------------------------
  def item_color(item)
    text_color(item.display_color)
  end

  #--------------------------------------------------------------------------
  # ○ アクター n 番の職業名を取得
  #--------------------------------------------------------------------------
  def actor_class_name(n)
    actor = n >= 1 ? $game_actors[n] : nil
    actor ? actor.class.name : ""
  end

  #--------------------------------------------------------------------------
  # ○ アクター n 番の二つ名を取得
  #--------------------------------------------------------------------------
  def actor_nickname(n)
    actor = n >= 1 ? $game_actors[n] : nil
    actor ? actor.nickname : ""
  end

  # draw_textの制御文字の事前変換するver
  # \cは仕様上最後に設定された色で全て描画
  # \Iは\wとかで勝手に付与されるので削除
  def draw_text_plus(*args)
    text = if args[0].is_a?(Rect)
             1
           else
             4
           end
    oc = Color.new
    oc.set(contents.font.color)
    args[text] = convert_escape_characters(args[text])
    args[text].gsub!(/\eC\[(\d+)\]/i) do
      alpha = contents.font.color.alpha
      change_color(text_color(Regexp.last_match(1).to_i))
      contents.font.color.alpha = alpha
      ""
    end
    args[text].gsub!(/\eI\[(\d+)\]/i) do
      ""
    end
    draw_text(*args)
    change_color(oc)
  end

  def draw_text_autosizing(*args)
    f = contents.font.size

    x, y, width, height, text, align = if args[0].is_a?(Rect)
                                         r = args[0]
                                         [r.x, r.y, r.width, r.height, args[1], args[2]]
                                       else
                                         args
                                       end
    t = nil
    align ||= 0
    loop do
      t = text_size(text)
      break if (t.width * 2 / 3) <= width

      contents.font.size -= 1
    end
    y += (height - t.height) / 2
    draw_text(x, y, width, t.height, text, align)
    contents.font.size = f
  end

  def draw_text(*args)
    return @contents_builder.draw_text(*args) if @contents_builder

    contents.draw_text(*args)
  end

  def start_contents_build
    @contents_builder = Hima::ContentsBuilder.new
  end

  def build_contents
    self.contents = @contents_builder.contents
    @contents_builder = nil
  end

  def show_key_text
    []
  end

  def draw_number_unit(*args)
    rect_flag = args[0].is_a?(Rect)
    x = rect_flag ? args[0].x : args[0]
    y = rect_flag ? args[0].y : args[1]
    width = rect_flag ? args[0].width : args[2]
    height = rect_flag ? args[0].height : args[3]
    number = rect_flag ? args[1] : args[4]
    align = rect_flag ? args[2] : args[5]
    digit = drawable_digit(width)
    if digit < number.digit
      draw_text(x, y, width, height, number.give_unit_floor(digit), align)
    else
      draw_text(*args)
    end
  end

  def drawable_digit(width)
    contents.drawable_digit(width)
  end

  def draw_actor_tp_vga(actor, x, y, width = 124)
    draw_gauge(x, y, width, [actor.tp_rate, 1.0].min, tp_gauge_color1, tp_gauge_color2)
    draw_current_and_max_values(x, y, width, actor.tp, actor.max_tp, tp_color(actor), normal_color, Vocab.tp_a)
  end

  def draw_actor_hp_vga(actor, x, y, width = 124)
    draw_gauge(x, y, width, [actor.hp_rate, 1.0].min, hp_gauge_color1, hp_gauge_color2)
    draw_current_and_max_values(x, y, width, actor.hp, actor.mhp, hp_color(actor), normal_color, Vocab.hp_a)
  end

  def draw_actor_mp_vga(actor, x, y, width = 124)
    draw_gauge(x, y, width, [actor.mp_rate, 1.0].min, mp_gauge_color1, mp_gauge_color2)
    draw_current_and_max_values(x, y, width, actor.mp, actor.mmp, mp_color(actor), normal_color, Vocab.mp_a)
  end

  def draw_current_and_max_values(x, y, width, current, max, color1, color2, name = nil)
    tw = width
    if name
      change_color(system_color)
      draw_text(x, y, 30, line_height, name)
      text_width = [text_size(name).width, 30].min
      x += text_width
      tw -= text_width
    end
    change_color(color1)
    if width < 96
      draw_number_unit(x, y, tw, line_height, current, 2)
    else
      size = (tw - 12) / 2
      draw_number_unit(x, y, size, line_height, current, 2)
      change_color(color2)
      draw_text(x + size, y, 12, line_height, "/", 2)
      draw_number_unit(x + size + 12, y, size, line_height, max, 2)
    end
  end

  def draw_text_ex(x, y, text, width = nil)
    clear_reduce_flag
    reset_font_settings
    text = convert_escape_characters(text)
    pos = { :x => x, :y => y, :new_x => x, :height => calc_line_height(text), :width => width }
    process_character(text.slice!(0, 1), text, pos) until text.empty?
  end

  def process_new_line(text, pos)
    clear_reduce_flag
    pos[:x] = pos[:new_x]
    pos[:y] += pos[:height]
    pos[:height] = calc_line_height(text)
  end

  def clear_reduce_flag
    @reduce_flag = nil
  end

  def reflect_reduce_contents(pos)
    draw_area_width = contents.width - pos[:new_x]
    line_rect = Rect.new(pos[:new_x], pos[:y], draw_area_width, line_height)
    contents.clear_rect(line_rect)
    dest_rect = Rect.new(pos[:new_x], 0, draw_area_width, contents.height)
    contents.stretch_blt(dest_rect, @reduce_bitmap, @reduce_bitmap.rect)
  end

  def text_auto_reduce?
    false
  end

  # 〇 これから表示する行が、表示領域から横にはみ出るかの判定とその際の処理
  def setup_reduce_over_line(c, text, pos)
    return unless text_auto_reduce?
    return unless @reduce_flag.nil?

    @reduce_flag = false
    if @reduce_bitmap
      @reduce_bitmap.dispose
      @reduce_bitmap = nil
    end
    text = c + text unless ['\n', '\f'].include?(c)
    return if text.empty?

    line_text = text.split(/\n|\f/)[0]
    return unless line_text

    line_text_width = text_size_ex(line_text).width
    total_width = pos[:new_x] + line_text_width
    over_flag = total_width > contents.width
    return unless over_flag

    @reduce_flag = true
    @reduce_bitmap = Bitmap.new(line_text_width, contents.height)
  end
end

class Window_BattleActor < Window_BattleStatus
  #--------------------------------------------------------------------------
  # ● 選択項目の有効状態を取得 【オーバーライド】
  #--------------------------------------------------------------------------
  def current_item_enabled?
    enable?($game_party.battle_members[index])
  end

  #--------------------------------------------------------------------------
  # ● ターゲットを許可状態で表示するかどうか
  #--------------------------------------------------------------------------
  def enable?(target)
    return if BattleManager.actor.nil?

    sex = target.sex
    ext = BattleManager.actor.input.item.ext_scope
    return true if ext == NWSex::ALL

    (sex & ext) != 0
  end

  #--------------------------------------------------------------------------
  # ● 名前の描画 【オーバーライド】
  #--------------------------------------------------------------------------
  def draw_actor_name(actor, x, y, width = 144)
    change_color(hp_color(actor), enable?(actor))
    draw_text(x, y, width, line_height, actor.name)
  end
end
class Window_BattleActorStatus < Window_Base
  def initialize(x, y)
    super(x, y, window_width, window_height)
    refresh
  end

  def window_width
    Graphics.width / 4
  end

  def window_height
    fitting_height(3)
  end

  def actor=(actor)
    if @actor != actor
      @actor = actor
      refresh
    end
  end

  def update
    super
    return unless @actor

    refresh if @hp != @actor.hp || @mp != @actor.mp || @mhp != @actor.mhp || @mmp != @actor.mmp
    @hp = @actor.hp
    @mp = @actor.mp
    @mhp = @actor.mhp
    @mmp = @actor.mmp
  end

  def refresh
    contents.clear
    return unless @actor

    y = 0
    change_color(hp_color(@actor))
    draw_text(0, y, contents_width, line_height, @actor.name)
    y += line_height
    draw_actor_hp(@actor, 0, y, contents_width)
    y += line_height
    draw_actor_mp(@actor, 0, y, contents_width)
  end
end

class Window_BattleEnemy < Window_Selectable
  #--------------------------------------------------------------------------
  # ○ オブジェクト初期化
  #     info_viewport : 情報表示用ビューポート
  #--------------------------------------------------------------------------
  def initialize(info_viewport)
    super(0, info_viewport.rect.y, window_width, fitting_height(4))
    refresh
    self.visible = false
    @info_viewport = info_viewport
    @friend_draw = false
  end

  #--------------------------------------------------------------------------
  # ● 選択項目の有効状態を取得【オーバーライド】
  #--------------------------------------------------------------------------
  def current_item_enabled?
    enable?($game_troop.alive_members[index])
  end

  #--------------------------------------------------------------------------
  # ● ターゲットを許可状態で表示するかどうか
  #--------------------------------------------------------------------------
  # Window_BattleActorとは基底クラスが違います
  def enable?(target)
    return if BattleManager.actor.nil?

    sex = target.sex
    ext = BattleManager.actor.input.item.ext_scope
    return true if ext == NWSex::ALL

    (sex & ext) != 0
  end

  #--------------------------------------------------------------------------
  # ● 友好度表示の設定
  #--------------------------------------------------------------------------
  attr_writer :friend_draw

  #--------------------------------------------------------------------------
  # ○ 項目の描画
  #--------------------------------------------------------------------------
  def draw_item(index)
    e = $game_troop.alive_members[index]
    name = e.name.clone
    color = normal_color
    if @friend_draw
      if !BattleManager.follower_disable? && $game_party.followable?(e)
        color = text_color(23)
      end
      name += "(友好度:#{e.enemy.ex_dungeon_enemy? ? 'なし' : e.friend})"
    end
    change_color(color, enable?(e))
    rect = item_rect_for_text(index)
    e.state_icons[0..1].reverse_each do |icon|
      rect.width -= 26
      draw_icon(icon, rect.x + rect.width, rect.y)
    end
    draw_text(rect, name)
  end
end

class Window_BattleItem < Window_ItemList
  #--------------------------------------------------------------------------
  # ● アクターの設定
  #--------------------------------------------------------------------------
  def actor=(actor)
    return if @actor == actor

    @actor = actor
    refresh
    self.oy = 0
  end

  #--------------------------------------------------------------------------
  # ○ アイテムをリストに含めるかどうか
  #--------------------------------------------------------------------------
  def include?(item)
    item.is_a?(RPG::Item) && item.battle_ok?
  end

  #--------------------------------------------------------------------------
  # ○ スキルを許可状態で表示するかどうか
  #--------------------------------------------------------------------------
  def enable?(item)
    @actor && @actor.usable?(item)
  end
end

class Window_BattleLog < Window_Selectable
  attr_reader :popup

  #--------------------------------------------------------------------------
  # ○ オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize
    super(0, Graphics.height - window_height, window_width, window_height)
    self.z = 200
    @lines = []
    @num_wait = 0
    @popup = PopupResults.new
    refresh
  end

  #--------------------------------------------------------------------------
  # ● ウィンドウを開く
  #--------------------------------------------------------------------------
  def open
    self.openness = 255
    self
  end

  #--------------------------------------------------------------------------
  # ● ウィンドウを閉じる
  #--------------------------------------------------------------------------
  def close
    self.openness = 0
    self
  end

  #--------------------------------------------------------------------------
  # ○ 解放
  #--------------------------------------------------------------------------
  def dispose
    super
  end

  #--------------------------------------------------------------------------
  # ○ リフレッシュ
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    @lines.size.times { |i| draw_line(i) }
  end

  #--------------------------------------------------------------------------
  # ○ クリア
  #--------------------------------------------------------------------------
  def clear
    @num_wait = 0
    @lines.clear
    @popup.clear
    refresh
  end

  #--------------------------------------------------------------------------
  # ○ 文章の追加
  #--------------------------------------------------------------------------
  def add_text(text)
    @lines.shift if max_line_number <= line_number
    @lines.push(text)
    refresh
  end

  #--------------------------------------------------------------------------
  # ○ 最大行数の取得
  #--------------------------------------------------------------------------
  def max_line_number
    4
  end

  #--------------------------------------------------------------------------
  # ○ 被ダメージセリフ用メソッドの設定
  #--------------------------------------------------------------------------
  attr_writer :method_process_down_word

  #--------------------------------------------------------------------------
  # ○ 被ダメージセリフ用処理
  #--------------------------------------------------------------------------
  def process_down_word(target, item)
    @method_process_down_word.call(target, item)
  end

  #--------------------------------------------------------------------------
  # ○ スキル／アイテム使用の表示
  #--------------------------------------------------------------------------
  def display_use_item(subject, targets, item)
    if item.is_skill?
      return if item.message1.empty? && item.message2.empty?

      text1 = if item.message1 =~ /\\(u|e)/i
                replace_ext_character(item.message1, subject,
                                      targets)
              else
                (subject.name + item.message1)
              end
      add_text(text1)
      unless item.message2.empty?
        wait
        text2 = item.message2 =~ /\\(u|e)/i ? replace_ext_character(item.message2, subject, targets) : item.message2
        add_text(text2)
      end
    else
      form = item.throw? ? Vocab::ThrowItem : Vocab::UseItem
      add_text(format(form, subject.name, item.name))
    end
  end

  #--------------------------------------------------------------------------
  # ○ 行動結果の表示
  #--------------------------------------------------------------------------
  def display_action_results(target, item, user = nil)
    return unless target.result.used
    return if item && item.no_display_action_result?

    last_line_number = line_number
    display_critical(target, item)
    display_damage(target, item)
    display_stealed(target)
    display_stand(target)
    display_restoration(target, user)
    display_invalidate_wall(target)
    display_defense_wall(target)
    display_binding_start(target)
    display_bind_resist(target)
    process_down_word(target, item)
    display_predation(target)
    display_affected_status(target, item)
    display_failure(target, item)
    wait if line_number > last_line_number
    back_to(last_line_number)
  end

  #--------------------------------------------------------------------------
  # ● ダメージの表示 Window_BattleLog 290
  #--------------------------------------------------------------------------
  def display_damage(target, item)
    return if target.result.invalidate_wall

    if target.result.missed
      display_miss(target, item)
    elsif target.result.evaded
      display_evasion(target, item)
    elsif target.result.blocked
      display_block(target, item)
    else
      display_hp_damage(target, item)
      display_mp_damage(target, item)
      display_tp_damage(target, item)
    end
  end

  def display_block(target, item)
    Audio.se_play("Audio/SE/Evasion2")
    add_text(format(Vocab::Block, target.name))
    wait
  end

  def display_tp_damage(target, item)
    return if target.enemy? || target.dead? || target.result.tp_damage == 0

    Sound.play_recovery if target.result.tp_damage < 0
    add_text(target.result.tp_damage_text)
    wait
  end

  #--------------------------------------------------------------------------
  # ○ HP ダメージ表示
  #--------------------------------------------------------------------------
  def display_hp_damage(target, item)
    return if target.result.hp_damage == 0 && item.nil?
    return if target.result.hp_damage == 0 && item && !item.damage.to_hp?

    target.perform_damage_effect if target.result.hp_damage > 0 && target.result.hp_drain == 0
    Sound.play_recovery if target.result.hp_damage < 0
    add_text(target.result.hp_damage_text)
    if target.result.hp_damage > 0 && target.result.element_rate && target.result.element_rate > 1.0
      @popup.push_hp_damage_elements(target.result.elements)
    end
    @popup.push_ex_category_boost(target.result.ex_category_boost)
    @popup.push_state_boost(target.result.state_boost)
    wait
  end

  #--------------------------------------------------------------------------
  # ● 反射の表示
  #--------------------------------------------------------------------------
  def display_reflection(target, item)
    Sound.play_reflection
    if item.physical? || item.certain?
      add_text(format(Vocab::PhysicalReflection, target.name))
    else
      add_text(format(Vocab::MagicReflection, target.name))
    end
    wait
    back_one
  end

  #--------------------------------------------------------------------------
  # ● スキル使用失敗
  #--------------------------------------------------------------------------
  def display_unusable(subject, item)
    return unless item.is_skill?

    add_text(subject.result.unusable_text)
    wait_and_clear
  end

  #--------------------------------------------------------------------------
  # ● 捕食
  #--------------------------------------------------------------------------
  def display_predation(subject)
    return unless subject.result.predation

    add_text(format(Vocab::Predation, subject.name))
    wait
  end

  #--------------------------------------------------------------------------
  # ● 永久拘束失敗
  #--------------------------------------------------------------------------
  def display_eternal_bind_resist(bind_user)
    add_text(format(Vocab::EternalBindResist, bind_user.name))
    wait_and_clear
  end

  #--------------------------------------------------------------------------
  # ● スキル対象不在の表示
  #--------------------------------------------------------------------------
  def display_target_empty(subject)
    add_text("#{subject.name}は様子を見ている……")
    wait_and_clear
  end

  #--------------------------------------------------------------------------
  # ● 自己付与
  #--------------------------------------------------------------------------
  def display_user_self_enchant(user, state_id)
    state = $data_states[state_id]
    unless state.message1.empty?
      add_text(user.name + state.message1)
      wait
      wait
    end
  end

  #--------------------------------------------------------------------------
  # ● ダメージ還元
  #--------------------------------------------------------------------------
  def display_restoration(subject, user)
    return unless subject.result.restoration?

    add_text(subject.result.restoration_text(user))
    wait
  end

  #--------------------------------------------------------------------------
  # ● 踏みとどまりの表示
  #--------------------------------------------------------------------------
  def display_stand(target)
    return unless target.result.auto_stand

    add_text(format(Vocab::Stand, target.name))
    wait
  end

  #--------------------------------------------------------------------------
  # ● 時間停止の表示
  #--------------------------------------------------------------------------
  def display_over_drive(target, user)
    add_text(format(Vocab::OverDriveSuccess, user.name))
    wait
  end

  #--------------------------------------------------------------------------
  # ● 無効化障壁の表示
  #--------------------------------------------------------------------------
  def display_invalidate_wall(target)
    return unless target.result.invalidate_wall

    add_text(format(Vocab::Invalidate, target.name))
    wait
  end

  #--------------------------------------------------------------------------
  # ● 防御壁展開の表示
  #--------------------------------------------------------------------------
  def display_defense_wall(target)
    return unless target.result.defense_wall

    add_text(format(Vocab::DefenseWall, target.name))
    wait
  end

  #--------------------------------------------------------------------------
  # ● 拘束開始の表示
  #--------------------------------------------------------------------------
  def display_binding_start(target)
    return unless target.result.binding_start >= 0

    index = target.result.binding_start
    add_text(format(Vocab::BindingStart[index], target.name))
    wait
  end

  #--------------------------------------------------------------------------
  # ● もがくの表示
  #--------------------------------------------------------------------------
  def display_bind_resist(target)
    return unless target.result.bind_resist

    if BattleManager.bind?
      add_text(format(Vocab::BindResistFailure, target.name))
    else
      add_text(format(Vocab::BindResistSuccess, target.name))
    end
    wait
  end

  #--------------------------------------------------------------------------
  # ● 反撃の表示
  #--------------------------------------------------------------------------
  def display_counter(target, item)
    Sound.play_evasion
    add_text(format(Vocab::CounterAttack, target.name))
    wait
  end

  #--------------------------------------------------------------------------
  # ● 自爆スキルの表示
  #--------------------------------------------------------------------------
  def display_pay_life(user)
    add_text(format(Vocab::PayLife, user.name))
    user.perform_collapse_effect
    wait
  end

  #--------------------------------------------------------------------------
  # ● 自爆スキル未遂の表示
  #--------------------------------------------------------------------------
  def display_pay_life_failure(user)
    add_text(format(Vocab::PayLifeFailure, user.name))
    wait
  end

  #--------------------------------------------------------------------------
  # ● スロット文章の表示
  #--------------------------------------------------------------------------
  def display_slot
    add_text(NWConst::Slot::PLAY_DESC)
  end

  #--------------------------------------------------------------------------
  # ○ 失敗の表示
  #--------------------------------------------------------------------------
  def display_failure(target, item)
    return if item && item.ignore_no_effect

    if target.result.hit? && !target.result.success
      add_text(format(Vocab::ActionFailure, target.name))
      wait
    end
  end

  def display_over_drive_failure
    add_text(Vocab::OverDriveFailure)
    wait
  end

  def replace_ext_character(original_text, subject, targets)
    text = original_text.dup
    text.gsub!(/\\u/i) { subject.name }
    text.gsub!(/\\e/i) { targets.first.name + (2 <= targets.uniq.size ? "達" : "") }
    text
  end

  def display_miss(target, item)
    return unless item

    fmt = target.actor? ? Vocab::ActorNoHit : Vocab::EnemyNoHit
    Sound.play_miss
    add_text(format(fmt, target.name))
    wait
  end

  #--------------------------------------------------------------------------
  # ● スティール実行結果の表示
  #--------------------------------------------------------------------------
  def display_stealed(target)
    return unless target.result.stealed

    unless target.result.stealed_items.empty?
      target.result.stealed_items.each do |item|
        add_text(format(Vocab::Stealed, target.name, item.object.window_name))
        wait
      end
      return
    end

    return add_text(format(Vocab::StealedItemEmpty, target.name)) if target.result.stealed_item_empty

    add_text(format(Vocab::StealFailure, target.name))
  end

  def display_added_state(target, state)
    state_msg = target.actor? ? state.message1 : state.message2
    state_msg = Vocab::PleasureFinished if target.result.pleasure && (state.id == target.death_state_id)
    if target.enemy? && (state.id == target.death_state_id) && !target.enemy.defeat_message.empty?
      state_msg = target.enemy.defeat_message
    end
    case state.id
    when NWConst::State::INSTANT_DEAD
      Audio.se_play("Audio/SE/Darkness5")
    when NWConst::State::INSTA2
      Audio.se_play("Audio/SE/Saint7")
    when NWConst::State::INSTA3
      Audio.se_play("Audio/SE/Darkness2")
    end
    target.perform_collapse_effect if state.death?
    return if state_msg.empty?

    replace_text(target.name + state_msg)
    wait
    wait_for_effect
  end

  def display_added_states(target)
    target.result.added_state_objects.each do |state|
      display_added_state(target, state)
    end
  end

  def display_removed_states(target)
    target.result.removed_state_objects.each do |state|
      display_removed_stete(target, state)
    end
  end

  def display_removed_stete(target, state)
    return if state.message4.empty?

    replace_text(target.name + state.message4)
    wait
  end

  def display_critical(target, item)
    texts = []
    if target.result.critical
      texts << (target.actor? ? Vocab::CriticalToActor : Vocab::CriticalToEnemy)
    end
    texts << Vocab::EX_CATEGORY_BOOST unless target.result.ex_category_boost.empty?
    texts << Vocab::STATE_BOOST unless target.result.state_boost.empty?
    return if texts.empty?

    add_text(texts.join("　"))
    wait
  end

  def draw_line(line_number)
    rect = item_rect_for_text(line_number)
    contents.clear_rect(rect)
    draw_text_ex(rect.x, rect.y, @lines[line_number])
  end

  def text_auto_reduce?
    true
  end

  def update
    super
    @popup.update
  end

  def dispose
    super
    @popup.clear
  end
end

class Window_BattleSkill
  
end
class Window_BattleStatus < Window_Selectable
  #--------------------------------------------------------------------------
  # ● アクター名の描画
  #--------------------------------------------------------------------------
  def draw_actor_name_ex(actor, x, y, enabled)
    change_color(hp_color(actor), enabled)
    draw_text(x, y, 100, line_height, actor.name)
  end

  #--------------------------------------------------------------------------
  # ○ 基本エリアの描画
  #--------------------------------------------------------------------------
  def draw_basic_area(rect, actor)
    draw_actor_name_ex(actor, rect.x + 0, rect.y, !(BattleManager.shift_change? && BattleManager.bind? && actor.luca?))
    draw_actor_icons(actor, rect.x + 104, rect.y, rect.width - 104)
  end

  #--------------------------------------------------------------------------
  # ● 現在選択中のメンバー位置を取得
  #--------------------------------------------------------------------------
  def member_index
    index
  end

  #--------------------------------------------------------------------------
  # ● 選択項目の有効状態を取得
  #--------------------------------------------------------------------------
  def current_item_enabled?
    !(BattleManager.shift_change? && BattleManager.bind? && $game_party.all_members[member_index].luca?)
  end

  #--------------------------------------------------------------------------
  # ○ ウィンドウ幅の取得
  #--------------------------------------------------------------------------
  def window_width
    Graphics.width - 200
  end

  #--------------------------------------------------------------------------
  # ○ ゲージエリアの幅を取得
  #--------------------------------------------------------------------------
  def gauge_area_width
    220
  end

  #--------------------------------------------------------------------------
  # ○ ゲージエリアの描画（TP あり）
  #--------------------------------------------------------------------------
  def draw_gauge_area_with_tp(rect, actor)
    draw_actor_hp(actor, rect.x + 0, rect.y, 70)
    draw_actor_mp(actor, rect.x + 80, rect.y, 70)
    draw_actor_tp(actor, rect.x + 160, rect.y, 50)
  end

  #--------------------------------------------------------------------------
  # ○ ゲージエリアの描画（TP なし）
  #--------------------------------------------------------------------------
  def draw_gauge_area_without_tp(rect, actor)
    draw_actor_hp(actor, rect.x + 0, rect.y, 130)
    draw_actor_mp(actor, rect.x + 140, rect.y, 70)
  end
end
class Window_Command
  def command_ext(index)
    @list[index][:ext]
  end
end

class Window_DebugRight < Window_Selectable
  #--------------------------------------------------------------------------
  # ● 選択項目の再描画
  #--------------------------------------------------------------------------
  def redraw_current_item
    refresh
  end
end


class Window_EnchantItemList < Window_ItemList
  attr_writer :stone_list_window
  attr_writer :equip_stone_window

  def initialize(x, y, w, h)
    super(x, y, w, h)
    refresh
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
  # ○ 項目の選択（オーバーライド）
  #--------------------------------------------------------------------------
  def select(index)
    super
    @equip_stone_window.item = item
  end

  def select_item(item)
    index = 0
    index = @data.index(item) || @data.index(item.base_data) || 0 if item
    select(index)
  end

  #--------------------------------------------------------------------------
  # ● アイテムリストの作成
  #--------------------------------------------------------------------------
  def make_item_list
    @data = $game_party.equip_items { |e| e }
    @data.uniq!
    @data.select! { |item| include?(item) }
    @data.select! { |item| item.favorite? } if @favorite_mode
    @data.select! { |item| item.include_item_list }
    @data.sort_by! do |item|
      sort_obj = [0, item.sort_obj]
      sort_obj[0] =
        if !item.uniq_item?
          1
        elsif item.equip_actor
          0
        elsif $game_party.storehouse_item_number(item) > 0
          2
        else
          1
        end

      sort_obj
    end
  end

  #--------------------------------------------------------------------------
  # ● アイテムを許可状態で表示するかどうか
  #--------------------------------------------------------------------------
  def enable?(item)
    item && item.socket?
  end

  def include?(item)
    super(item) && item.socket? && (item.uniq_item? || $game_party.item_number(item) > 0)
  end

  #--------------------------------------------------------------------------
  # ● 項目の描画
  #--------------------------------------------------------------------------
  def draw_item(index)
    item = @data[index]
    if item
      rect = item_rect(index)
      # rect.width -= 4
      draw_item_name(item, rect.x, rect.y, enable?(item))
      draw_item_number(rect, item) if !item.enchant_item? && $game_party.item_number(item) > 1
    end
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

class Window_EquipItem < Window_ItemList
  def include?(item)
    return true if item.nil?
    return false unless item.is_a?(RPG::EquipItem)
    return false if @slot_id < 0

    @actor.equippable?(item) && @actor.equippable_slot?(@slot_id, item)
  end

  def update_help
    super
    if @actor && @status_window
      temp_actor = Marshal.load(Marshal.dump(@actor))
      temp_actor.extend OverrideStones
      temp_actor.force_change_equip(@slot_id, item)
      @status_window.set_temp_actor(temp_actor)
    end
  end

  def process_handling
    return unless open? && active
    return process_ok       if ok_enabled?        && Input.trigger?(:C)
    return process_cancel   if cancel_enabled?    && Input.trigger?(:B)
    return process_pagedown if handle?(:pagedown) && Input.trigger?(:R)
    return process_pageup   if handle?(:pageup)   && Input.trigger?(:L)
    return process_sub      if handle?(:A)        && Input.trigger?(:A)
  end

  def process_sub
    Input.update
    call_handler(:A)
  end
end

module OverrideStones
  def bactor
    $game_actors[id]
  end

  def stones_armor_data
    bactor.stones_armor_data
  end
end
class Window_EquipItemCategory < Window_ItemCategory
  #--------------------------------------------------------------------------
  # ● 桁数の取得
  #--------------------------------------------------------------------------
  def col_max
    2
  end

  #--------------------------------------------------------------------------
  # ● コマンドリストの作成
  #--------------------------------------------------------------------------
  def make_command_list
    add_command(Vocab.weapon,   :weapon)
    add_command(Vocab.armor,    :armor)
  end
end
class Window_EquipSlot < Window_Selectable
  def process_handling
    return unless open? && active
    return process_ok       if ok_enabled?        && Input.trigger?(:C)
    return process_cancel   if cancel_enabled?    && Input.trigger?(:B)
    return process_pagedown if handle?(:pagedown) && Input.trigger?(:R)
    return process_pageup   if handle?(:pageup)   && Input.trigger?(:L)
    return process_sub      if handle?(:A)        && Input.trigger?(:A)
    return process_y        if handle?(:Y)        && Input.trigger?(:Y)
  end
  def visible_line_number
    6
  end
  #--------------------------------------------------------------------------
  # ● サブキー(Aボタン)が押されたときの処理
  #--------------------------------------------------------------------------
  def process_sub
    Input.update
    call_handler(:A)
  end

  def process_y
    Input.update
    call_handler(:Y)
  end

  def slot_name(index)
    @actor ? @actor.slot_name(index) : ""
  end

  def draw_item_name(item, x, y, enabled = true, width = 236)
    if item && item.socket?
      stones = item.stones
      icon_x = stones.count * 12
      stones.each do |stone|
        icon_id = stone ? stone.icon_index : 3471
        draw_icon(icon_id, x + width - icon_x, y, enabled)
        icon_x -= 12
      end
      width -= stones.count * 12 - 12
    end
    super(item, x, y, enabled, width)
  end
end

class Window_EquipStatus < Window_Base
  alias h_window_equipstatus_initialize initialize
  def initialize(x, y)
    @params = {}
    h_window_equipstatus_initialize(x, y)
  end

  def refresh
    @params = {}
    refresh_temp
  end

  def visible_line_number
    8
  end
  
  def draw_current_param(x, y, param_id)
    change_color(normal_color)
    @params[param_id] ||= @actor.param(param_id)
    draw_number_unit(x, y, 42, line_height, @params[param_id], 2)
  end

  def draw_new_param(x, y, param_id)
    new_value = @temp_actor.param(param_id)
    change_color(param_change_color(new_value - @params[param_id]))
    draw_number_unit(x, y, 42, line_height, new_value, 2)
  end

  def refresh_temp
    contents.clear
    draw_actor_name(@actor, 4, 0) if @actor
    [*2..7,0].each_with_index { |param_id, i| draw_item(0, line_height * (1 + i), param_id) }
  end

  def set_temp_actor(temp_actor)
    return if @temp_actor == temp_actor

    @temp_actor = temp_actor
    refresh_temp
  end

  #--------------------------------------------------------------------------
  # ○ 項目の描画
  #--------------------------------------------------------------------------
  def draw_item(x, y, param_id)
    draw_param_name(x + 4, y, param_id)
    draw_current_param(x + 74, y, param_id) if @actor
    draw_right_arrow(x + 116, y)
    draw_new_param(x + 140, y, param_id) if @temp_actor
  end
end

class Window_EquipStone < Window_Command
  #--------------------------------------------------------------------------
  # ● 公開インスタンス変数
  #-------------------------------------------------------------------------
  attr_reader :item

  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize
    @item = nil
    super(0, fitting_height(2) + fitting_height(1) + fitting_height(5))
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
    Graphics.height - (fitting_height(2) + fitting_height(1) + fitting_height(5))
  end

  #--------------------------------------------------------------------------
  # ● アイテムの設定
  #--------------------------------------------------------------------------
  def item=(item)
    unless @item == item
      @item = item
      refresh
    end
  end

  #--------------------------------------------------------------------------
  # ● コマンドリストの作成
  #--------------------------------------------------------------------------
  def make_command_list
    return unless @item

    @item.stones.each do |stone|
      add_command(stone, :ok, true)
    end
  end

  #--------------------------------------------------------------------------
  # ● 項目の描画
  #--------------------------------------------------------------------------
  def draw_item(index)
    prefix_text = "E:"
    rect = item_rect_for_text(index)
    change_color(normal_color)
    draw_text(rect, prefix_text)
    return unless command_name(index)

    rect.x += text_size(prefix_text).width
    rect.width -= text_size(prefix_text).width
    draw_item_name(command_name(index), rect.x, rect.y, command_enabled?(index))
    change_color(system_color)
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
    @help_window.set_item(command_name(index))
  end
end

#==============================================================================
# ■ Window_Help
#==============================================================================
class Window_Help < Window_Base
  #--------------------------------------------------------------------------
  # ○ リフレッシュ
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    rect = Rect.new(4, 0, contents.width - 4, line_height)
    @text.lines do |text|
      draw_text_plus(rect, text.chomp)
      rect.y += line_height
    end
  end
end

#==============================================================================
# ■ Window_Help_Color
#==============================================================================
class Window_Help_Color < Window_Help
  #--------------------------------------------------------------------------
  # ● リフレッシュ
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    x = 4
    y = 0
    @text.lines do |text|
      draw_text_ex(4, y, text)
      y += line_height
    end
  end
end

class Window_ItemCategory < Window_HorzCommand
  def col_max
    col = 3
    col += 1 if display_stone?
    col += 1 if display_key_item?
    col
  end

  #--------------------------------------------------------------------------
  # ● コマンドリストの作成
  #--------------------------------------------------------------------------
  def make_command_list
    add_command(Vocab.item,     :item)
    add_command(Vocab.weapon,   :weapon)
    add_command(Vocab.armor,    :armor)
    add_command(Vocab::ENCHANT_STONE, :enchant_stone) if display_stone?
    add_command(Vocab.key_item, :key_item) if display_key_item?
  end

  def display_stone?
    $game_party.display_stone_flag
  end

  def display_key_item?
    !$game_switches[NWConst::Sw::NO_DISPLAY_KEY_ITEM]
  end
end

class Window_ItemCost < Window_Base
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(super_window)
    @super_window = super_window
    @max_width = 0
    @max_item  = 0
    super(0, 0, window_width, window_height)
    self.arrows_visible = false
    hide
  end

  #--------------------------------------------------------------------------
  # ● ウィンドウ幅の取得
  #--------------------------------------------------------------------------
  def window_width
    w = [@max_width, 186].max
    plus_col = (@max_item - 1) / 4
    plus_col = 0 if @max_item == 5
    [w + (w + col_space) * plus_col + standard_padding * 2 + 8,
     Graphics.width].min
  end

  #--------------------------------------------------------------------------
  # ● 横に項目が並ぶときの空白の幅を取得
  #--------------------------------------------------------------------------
  def col_space
    (@max_item < 9 ? 16 : 0)
  end

  #--------------------------------------------------------------------------
  # ● ウィンドウ高さの取得
  #--------------------------------------------------------------------------
  def window_height
    fitting_height(4)
  end

  #--------------------------------------------------------------------------
  # ● ウィンドウ内容の幅を計算
  #--------------------------------------------------------------------------
  def contents_width
    Graphics.width
  end

  #--------------------------------------------------------------------------
  # ● ウィンドウ内容の高さを計算
  #--------------------------------------------------------------------------
  def contents_height
    Graphics.height
  end

  #--------------------------------------------------------------------------
  # ● リフレッシュ
  #--------------------------------------------------------------------------
  def refresh
    item = @super_window.item
    return hide if !item || item.item_cost.empty?

    contents.clear
    texts = item_text(item)
    i = 0
    dx = 4
    texts.delete_at(0) if (texts.size == 5) && (@max_item == 5)
    texts.each do |str|
      c = str.slice!(0, 1).to_i
      change_color(normal_color)
      contents.font.color.alpha = (c == 1 ? 255 : translucent_alpha)
      draw_text(dx, line_height * i, contents_width, line_height, str)
      i += 1
      next unless i >= 4

      i -= 4
      dx += @max_width + col_space
      i += 1 if texts.size < 8
    end
    border = Graphics.height - height
    sy = @super_window.cursor_y_down
    self.y = (sy > border ? @super_window.y : Graphics.height - height)
    show
  end

  #--------------------------------------------------------------------------
  # ● ウインドウサイズを変更
  #--------------------------------------------------------------------------
  def set_size(data)
    @max_width = 0
    @max_item  = 0
    data.each do |item|
      texts = item_text(item)
      texts.each do |str|
        str.slice!(0, 1)
        @max_width = [@max_width, contents.text_size(str).width].max
      end
      @max_item = [@max_item, texts.size].max
    end
    self.width  = window_width
    self.height = window_height
    self.x = Graphics.width  - width
    self.y = Graphics.height - height
  end

  #--------------------------------------------------------------------------
  # ● 表示する文章の配列
  #--------------------------------------------------------------------------
  def item_text(item)
    texts = ["1消費アイテム"]
    actor = @super_window.actor
    actor.skill_cost_item(item).each do |cost|
      cost_item = $data_items[cost[:id]]
      name = cost_item.name
      have = $game_party.item_number(cost_item)
      c = have >= cost[:num] ? 1 : 0
      texts.push(format("%d%s×%d（所持数：%d）", c, name, cost[:num], have))
    end
    texts
  end
end

class Window_ItemList < Window_Selectable
  attr_reader :favorite_mode

  def item_color(item)
    return tp_gauge_color2 if item.favorite?

    super
  end

  def draw_item_name(item, x, y, enabled = true, width = 236)
    if item && item.socket?
      stones = item.stones
      icon_x = stones.count * 12
      stones.each do |stone|
        icon_id = stone ? stone.icon_index : 3471
        draw_icon(icon_id, x + width - icon_x, y, enabled)
        icon_x -= 12
      end
      width -= stones.count * 12 - 12
    end
    super(item, x, y, enabled, width)
  end

  #--------------------------------------------------------------------------
  # ● アイテムをリストに含めるかどうか
  #--------------------------------------------------------------------------
  def include?(item)
    case @category
    when :item
      item.is_a?(RPG::Item) && !item.key_item? && !item.enchant_stone?
    when :weapon
      item.is_a?(RPG::Weapon)
    when :armor
      item.is_a?(RPG::Armor)
    when :key_item
      item.is_a?(RPG::Item) && item.key_item? && !item.enchant_stone?
    when :enchant_stone
      item.is_a?(RPG::Item) && item.enchant_stone?
    else
      false
    end
  end

  #--------------------------------------------------------------------------
  # ○ 指定されたアイテムにカーソルを移動　なければ0番にカーソルを移動
  #--------------------------------------------------------------------------
  def select_item(s_item)
    select_index = @data.index(s_item) || 0
    select(select_index)
  end

  #--------------------------------------------------------------------------
  # ○ 選択中のアイテムのお気に入り状態を取得
  #--------------------------------------------------------------------------
  def get_favorite_item_state
    $game_party.favorite_item?(item)
  end

  #--------------------------------------------------------------------------
  # ○ 選択中のアイテムのお気に入り状態を変更
  #--------------------------------------------------------------------------
  def set_favorite_item
    $game_party.set_favorite_item(item)
    update_help
  end

  #--------------------------------------------------------------------------
  # ○ お気に入り表示モードを変更
  #--------------------------------------------------------------------------
  def change_favorite_mode
    @favorite_mode = !@favorite_mode
  end

  #--------------------------------------------------------------------------
  # ● アイテムリストの作成
  #--------------------------------------------------------------------------
  def make_item_list
    @data = $game_party.all_items.select { |item| include?(item) }
    @data.reject! { |item| !$game_party.favorite_item?(item) } if @favorite_mode
    @data.push(nil) if include?(nil)
  end

  #--------------------------------------------------------------------------
  # ○ アイテムを許可状態で表示するかどうか
  #--------------------------------------------------------------------------
  alias h_window_itemlist_enable? enable?
  def enable?(item)
    h_window_itemlist_enable?(item) && (!item.warp_item? || WarpManager.usable?)
  end
end

class Window_ItemName < Window_Base
  attr_accessor :item

  def initialize
    super(0, 0, Graphics.width, 56)
    hide
  end

  def refresh
    contents.clear
    draw_item if item
  end

  def draw_item
    rect = Rect.new(0, 4, contents_width, line_height)
    enable = SceneManager.scene.equip_info_enable
    change_color(normal_color)
    draw_item_name(@item, rect.x, rect.y, enable, contents_width)
    change_color(normal_color, enable)
    draw_text(rect, @item.socket_name, 2) if @item.socket?
  end
end

class Window_MenuActor < Window_MenuStatus
  #--------------------------------------------------------------------------
  # ● 選択項目の有効状態を取得
  #--------------------------------------------------------------------------
  def current_item_enabled?
    true
  end
end
#==============================================================================
# ■ Window_MenuCommand
#==============================================================================
class Window_MenuCommand < Window_Command
  #--------------------------------------------------------------------------
  # ○ 主要コマンドをリストに追加
  #--------------------------------------------------------------------------
  def add_main_commands
    add_command(Vocab.item,   :item,   main_commands_enabled)
    add_command(Vocab.equip,  :equip,  equip_enabled?)
    add_command(Vocab::ENCHANT_STONE, :stone) if $game_switches[NWConst::Sw::MENU_ENCHANT_STONE]
    add_command(Vocab.skill,  :skill,  main_commands_enabled)
    add_skill_custom_commands
    add_command(Vocab.status, :status, main_commands_enabled)
  end

  def equip_enabled?
    main_commands_enabled && !$game_switches[NWConst::Sw::EQUIP_DISABLED]
  end

  #--------------------------------------------------------------------------
  # ● スキル装備コマンドをリストに追加
  #--------------------------------------------------------------------------
  def add_skill_custom_commands
    add_command(Vocab::Ability, :ability, main_commands_enabled)
  end

  #--------------------------------------------------------------------------
  # ○ 独自コマンドの追加用
  #--------------------------------------------------------------------------
  def add_original_commands
    add_command("図鑑", :library)
    add_command("コンフィグ", :config)
  end

  #--------------------------------------------------------------------------
  # ○ 並び替えの有効状態を取得
  #--------------------------------------------------------------------------
  def formation_enabled
    $game_party.members.size >= 2 && !$game_system.formation_disabled && $game_player.followers.visible
  end

  def process_handling
    return unless open? && active
    return process_ok if ok_enabled? && Input.trigger?(:C)
    return process_cancel if cancel_enabled? && Input.trigger?(:B)
    return process_pagedown if handle?(:pagedown) && Input.trigger?(:R)
    return process_pageup if handle?(:pageup) && Input.trigger?(:L)
    return process_extra if handle?(:extra) && Input.trigger?(:A)
  end

  def process_extra
    call_handler(:extra)
  end
end

class Window_MenuStatus < Window_Selectable
  #--------------------------------------------------------------------------
  # ○ 決定ボタンが押されたときの処理
  #--------------------------------------------------------------------------
  def process_ok
    if current_item_enabled?
      #      Sound.play_ok
      Input.update
      deactivate
      call_ok_handler
    else
      Sound.play_buzzer
    end
    $game_party.menu_actor = $game_party.members[index]
  end

  #--------------------------------------------------------------------------
  # ● 選択項目の有効状態を取得
  #--------------------------------------------------------------------------
  def current_item_enabled?
    return false if pending_index >= 0 && no_change_all_dead?

    true
  end

  #--------------------------------------------------------------------------
  # ● メンバー入れ替えでの全滅防止
  #--------------------------------------------------------------------------
  def no_change_all_dead?
    return true if $game_party.no_swap_all_dead?(index, pending_index)

    false
  end
end

class Window_Message < Window_Base
  #--------------------------------------------------------------------------
  # ○ ウェイト
  #--------------------------------------------------------------------------
  def wait(duration)
    return if Input.press?(:X)

    duration.times { Fiber.yield }
  end

  #--------------------------------------------------------------------------
  # ○ 一文字出力後のウェイト
  #--------------------------------------------------------------------------
  def wait_for_one_character
    return if Input.press?(:X)

    update_show_fast
    Fiber.yield unless @show_fast || @line_show_fast
  end

  def text_auto_reduce?
    true
  end

  #--------------------------------------------------------------------------
  # ○ 入力待ち処理
  #--------------------------------------------------------------------------
  def input_pause
    return if Input.press?(:X)

    self.pause = true
    wait(10)
    Fiber.yield until Input.trigger?(:B) || Input.trigger?(:C) || Input.trigger?(:X)
    Input.update
    self.pause = false
  end

  #--------------------------------------------------------------------------
  # ○ 制御文字の処理
  #     code : 制御文字の本体部分（「\C[1]」なら「C」）
  #     text : 描画処理中の文字列バッファ（必要なら破壊的に変更）
  #     pos  : 描画位置 {:x, :y, :new_x, :height}
  #--------------------------------------------------------------------------
  def process_escape_character(code, text, pos)
    case code.upcase
    when "$"
      @gold_window.open
    when "."
      wait(15)
    when "|"
      wait(60)
    when "!"
      input_pause
    when ">"
      @line_show_fast = true
    when "<"
      @line_show_fast = false
    when "^"
      @pause_skip = true
    when "D"
      screen = $game_party.in_battle ? $game_troop.screen : $game_party.in_novel ? $game_novel.screen : $game_map.screen
      screen.start_shake(5, 5, 10)
      Sound.play_actor_damage
    else
      super
    end
  end

  #--------------------------------------------------------------------------
  # ● 改ページ処理
  #--------------------------------------------------------------------------
  def new_page(text, pos)
    clear_reduce_flag
    contents.clear
    draw_face_hue($game_message.face_name, $game_message.face_index, $game_message.face_hue || 0, 0, 0)
    reset_font_settings
    pos[:x] = new_line_x
    pos[:y] = 0
    pos[:new_x] = new_line_x
    pos[:height] = calc_line_height(text)
    clear_flags
  end

end
class Window_Page < Window_Base
  attr_reader :page_index
  attr_reader :page_max

  def initialize
    super(0, Graphics.height - 56, Graphics.width, 56)
    hide
  end

  def page_max=(page_max)
    if @page_max != page_max
      @page_max = page_max
      refresh
    end
  end

  def page_index=(page)
    if @page_index != page
      @page_index = page
      refresh
    end
  end

  def refresh
    contents.clear
    draw_page if page_index && page_max
  end

  def draw_page
    rect = Rect.new(Graphics.width / 2 - 50, 4, 100, line_height)
    change_color(system_color)
    draw_text(rect, "←")
    draw_text(rect, "#{@page_index}/#{@page_max}", 1)
    draw_text(rect, "→", 2)
  end
end

class Window_PartyCommand < Window_Command
  #--------------------------------------------------------------------------
  # ○ 桁数の取得
  #--------------------------------------------------------------------------
  def col_max
    2
  end

  #--------------------------------------------------------------------------
  # ○ 横に項目が並ぶときの空白の幅を取得
  #--------------------------------------------------------------------------
  def spacing
    4
  end

  #--------------------------------------------------------------------------
  # ○ ウィンドウ幅の取得
  #--------------------------------------------------------------------------
  def window_width
    200
  end

  #--------------------------------------------------------------------------
  # ○ コマンドリストの作成
  #--------------------------------------------------------------------------
  def make_command_list
    add_command(Vocab.fight, :fight)
    add_command(Vocab.shift_change, :shift_change, can_shift_change?)
    add_command(Vocab::AUTOBATTLE, :auto_battle)
    add_command(Vocab.giveup,      :giveup, BattleManager.can_giveup?)
    add_command(Vocab.escape,      :escape, BattleManager.can_escape?)
    add_command(Vocab::BATTLE_STATES, :battle_states)
    add_command(Vocab.library,     :library)
    add_command(Vocab.config,      :config)
  end

  #--------------------------------------------------------------------------
  # ○ 入れ替えコマンドの可否
  #--------------------------------------------------------------------------
  def can_shift_change?
    return false if $game_party.bench_members.empty?
    return false if $game_switches[NWConst::Sw::FORBID_BATTLE_SHIFT_CHANGE]
    return false if $game_troop.challenge_battle?
    
    true
  end

  def setup
    clear_command_list
    make_command_list
    refresh
    select(0)
    select_symbol($game_system.last_select_battle_command) if $game_system.last_select_battle_command == :auto_battle
    activate
    open
  end

  def call_ok_handler
    super
    $game_system.last_select_battle_command = current_symbol
  end
end

class Window_Popup < Window_Selectable
  def initialize
    super(0, 0, 1, 1)
    self.z = 200
    self.openness = 0
  end

  def set_text(text)
    @text = text
  end

  def window_width
    [text_size(@text).width, Graphics.width].min + 20 + standard_padding * 2
  end

  def window_height
    fitting_height(1)
  end

  def process_ok
    Input.update
    deactivate
    call_ok_handler
  end

  def process_cancel
    Input.update
    deactivate
    call_cancel_handler
  end

  def update_open
    self.openness += 200
    @opening = false if open?
  end

  def update_close
    self.openness -= 200
    @closing = false if close?
  end

  def refresh
    move_x = (Graphics.width / 2) - (window_width / 2)
    move_y = (Graphics.height / 2) - (window_height / 2)
    move(move_x, move_y, window_width, window_height)
    update_padding
    create_contents
    rect = Rect.new(0, 0, contents_width, contents_height)
    draw_text(rect, @text, 1)
  end
end

class Window_Selectable < Window_Base
  alias h_window_selectable_initialize initialize
  def initialize(x, y, width, height)
    @draw = []
    h_window_selectable_initialize(x, y, width, height)
  end

  def refresh
    create_contents
    draw_all_items
  end

  def create_contents
    @draw = []
    super
  end

  def draw_all_items
    @draw = []
    draw_page
  end

  def draw_page
    index = top_row * col_max
    max = [(index + page_item_max + 1), item_max].min
    return if (max - index) <= 0

    (max - index).times do |i|
      next if @draw[i + index]

      @draw[i + index] = true
      draw_item(i + index)
    end
  end

  def index=(index)
    @index = index
    update_cursor
    call_update_help
    draw_page if index != 0
  end

  def oy=(oy)
    super
    draw_page
  end

  def ox=(ox)
    super
    draw_page
  end

  def process_pageup
    Sound.play_cursor
    Input.update
    deactivate unless handle?(:keep_on_actor_change)
    call_handler(:pageup)
  end

  def process_pagedown
    Sound.play_cursor
    Input.update
    deactivate unless handle?(:keep_on_actor_change)
    call_handler(:pagedown)
  end
end

class Window_ShopCompareEx < Window_Base
  include EquipInfoWindow
  #--------------------------------------------------------------------------
  # ● 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_accessor :status_window

  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize
    super(0, 56, Graphics.width, 368)
    create_contents
    @page_index = 0
    @data = []
    self.back_opacity = 192
    hide
  end

  #--------------------------------------------------------------------------
  # ● リフレッシュ
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    if @item.nil?
      change_color(normal_color, false)
      draw_text(0, 0, contents_width, line_height, "何も選択していません")
      return
    end
    return if @item.is_a?(RPG::Item)

    make_data
    draw_page
  end

  def make_data
    @data = $game_party.all_members.inject([]) do |a, actor|
      name = actor.name
      next a + [[name, actor, nil]] unless actor.equippable?(@item)

      slots = actor.slot_list(@item.etype_id).select { |id| actor.equip_change_ok?(id) }
      s = slots.select { |i| actor.equips[i] && actor.equips[i].etype_id == @item.etype_id }
      s = [slots.sort_by { |i| actor.equips[i].nil? ? 0 : -actor.equips[i].params[param_id] }.first] if s.empty?

      r = case s.size
          when 1
            [[name, actor, s.first]]
          else
            s.map do |slot_id|
              ["#{actor.name}(#{actor.slot_name(slot_id)})", actor, slot_id]
            end
          end
      a + r
    end
  end

  def draw_page
    s = @page_index * 6
    r = @data[s..(s + 6)] || []
    r.each_with_index do |(name, actor, slot_id), i|
      div, mod = i.divmod(6)
      x = div * contents.width + (contents.width / 2) * (mod % 2)
      y = 112 * (mod / 2)
      draw_actor_equip_info(x, y, name, actor, slot_id)
    end
  end

  def draw_actor_equip_info(x, y, name, actor, slot_id)
    reset_font_settings
    rect = Rect.new(x, y, contents.width / 2, line_height)
    enabled = !slot_id.nil?
    change_color(normal_color, enabled)
    draw_text(rect, name)
    rect.y += line_height
    current_item = slot_id.nil? ? nil : actor.equips[slot_id]
    draw_item_name(current_item, rect.x, rect.y, enabled)
    rect.y += line_height
    draw_item_param_change(actor, rect.x, rect.y, slot_id, enabled)
  end

  def draw_item_param_change(actor, x, y, slot_id, enable)
    unless enable
      rect = Rect.new(x, y, contents.width / 2, line_height)
      change_color(bad_color)
      draw_text(rect, NWConst::Shop::NotEquip)
      return
    end
    temp_actor = Marshal.load(Marshal.dump(actor))
    temp_actor.extend OverrideStones
    temp_actor.force_change_equip(slot_id, @item)
    base_rect = Rect.new(x, y, (contents.width / 2) / 3, 20)
    last_font = contents.font.size
    contents.font.size = 20
    [*2..7,0,1].each_with_index do |param_id, i|
      param = actor.param(param_id) - temp_actor.param(param_id)
      r = base_rect.clone
      r.x += base_rect.width  * (i % 3)
      r.y += base_rect.height * (i / 3)
      change_color(system_color)
      draw_text(r, Vocab.params_a(i), 0)
      r.x     += text_size(Vocab.params_a(i)).width
      r.width -= text_size(Vocab.params_a(i)).width
      color = [power_up_color, normal_color, power_down_color][(param <=> 0) + 1]
      prefix = ["＋", "±", "－"][(param <=> 0) + 1]
      change_color(color)
      param = param.abs
      param = param.give_unit_floor(4) if param >= 100_000_000
      draw_text(r, prefix + param.to_s, 0)
    end
    contents.font.size = last_font
  end

  #--------------------------------------------------------------------------
  # ● ページ数
  #--------------------------------------------------------------------------
  def page_max
    return 0 if @item.nil?
    return 0 if @item.is_a?(RPG::Item)

    @data.size / 6 + 1
  end

  def param_id
    @item.is_a?(RPG::Weapon) ? 2 : 3
  end
end

class Window_ShopNumber
  attr_reader :item
end
class Window_ShopStatus < Window_Base
  #--------------------------------------------------------------------------
  # ● ウィンドウの非アクティブ化
  #--------------------------------------------------------------------------
  def deactivate
    super
    refresh
  end

  #--------------------------------------------------------------------------
  # ○ リフレッシュ
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    return if @item.nil?

    draw_possession(4, 0)
    return unless active
    return if @item.is_a?(RPG::Item)

    draw_button(0, contents.height - (line_height * 2))
    return if page_max == 0

    method_name = draw_methods[@page_index][:name]
    index = draw_methods[@page_index][:index]
    send(method_name, 0, 28, index)
  end

  #--------------------------------------------------------------------------
  # ○ アイテムの設定
  #--------------------------------------------------------------------------
  def item=(item)
    @item = item
    @page_index = 0
    refresh
  end

  #--------------------------------------------------------------------------
  # ● 描画命令メソッド配列の取得
  #--------------------------------------------------------------------------
  def draw_methods
    methods = []
    param_page_max.times { |i| methods.push({ :name => :draw_params, :index => i }) }
    enchant_page_max.times { |i| methods.push({ :name => :draw_enchants, :index => i }) }
    methods
  end

  #--------------------------------------------------------------------------
  # ● ボタン説明の描画
  #--------------------------------------------------------------------------
  def draw_button(x, y)
    rect = Rect.new(x, y, contents.width, line_height)
    change_color(system_color)
    if 1 < page_max
      draw_text(rect, Help.shop_equip_change)
      draw_text(rect, "#{@page_index + 1}/#{page_max}", 2)
    end
    rect.y += line_height
    draw_text(rect, Help.shop_param_compare)
  end

  #--------------------------------------------------------------------------
  # ● 基礎性能の描画
  #--------------------------------------------------------------------------
  def draw_params(x, y, index)
    rect = Rect.new(x, y, contents.width, line_height)
    param_names = @item.param_names[index * NWConst::Shop::STATUS_MAX, NWConst::Shop::STATUS_MAX]
    change_color(system_color)
    draw_text(rect, "基礎性能")
    rect.y += line_height + 2
    change_color(normal_color)
    param_names.each  do |name|
      draw_text(rect, name)
      rect.y += line_height
    end
  end

  #--------------------------------------------------------------------------
  # ● 特殊効果の描画
  #--------------------------------------------------------------------------
  def draw_enchants(x, y, index)
    rect = Rect.new(x, y, contents.width, line_height)
    enchant_names = @item.enchant_names[index * NWConst::Shop::STATUS_MAX, NWConst::Shop::STATUS_MAX]
    change_color(system_color)
    draw_text(rect, "特殊効果")
    rect.y += line_height + 2
    change_color(normal_color)
    enchant_names.each do |name|
      draw_text_plus(rect, name)
      rect.y += line_height
    end
  end

  #--------------------------------------------------------------------------
  # ● 基礎性能最大ページ数の取得
  #--------------------------------------------------------------------------
  def param_page_max
    (@item.param_names.size - 1) / NWConst::Shop::STATUS_MAX + 1
  end

  #--------------------------------------------------------------------------
  # ● 特殊効果最大ページ数の取得
  #--------------------------------------------------------------------------
  def enchant_page_max
    (@item.enchant_names.size - 1) / NWConst::Shop::STATUS_MAX + 1
  end

  #--------------------------------------------------------------------------
  # ○ 最大ページ数の取得
  #--------------------------------------------------------------------------
  def page_max
    param_page_max + enchant_page_max
  end

  #--------------------------------------------------------------------------
  # ○ ページの更新
  #--------------------------------------------------------------------------
  def update_page
    return unless active

    if visible && @item.is_a?(RPG::EquipItem) && page_max > 1
      if Input.trigger?(:RIGHT)
        @page_index = (@page_index + 1) % page_max
        refresh
      elsif Input.trigger?(:LEFT)
        @page_index = ((@page_index - 1) + page_max) % page_max
        refresh
      end
    end
  end

  def current_equipped_item(actor, etype_id)
    list = actor.slot_list(etype_id).map { |slot_id| actor.equips[slot_id] }.select do |equip|
      equip.nil? || equip.etype_id == etype_id
    end
    list.min_by { |item| item ? item.params[param_id] : 0 }
  end
end

class Window_ShopStatusEx < Window_ShopStatus
  include EquipInfoWindow
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(x, y, width, height)
    super(x, y, width, height)
    self.back_opacity = 192
    self.z = 100
    hide
  end

  #--------------------------------------------------------------------------
  # ● アイテムの設定
  #--------------------------------------------------------------------------
  def item=(item)
    return if @item == item

    super(item)
  end

  #--------------------------------------------------------------------------
  # ● 色調の更新
  #--------------------------------------------------------------------------
  def update_tone
    tone.set($game_system.window_tone)
  end

  #--------------------------------------------------------------------------
  # ○ ページの更新
  #--------------------------------------------------------------------------
  def update_page
    nil
  end

  #--------------------------------------------------------------------------
  # ○ 最大ページ数の取得
  #--------------------------------------------------------------------------
  def page_max
    return 0 if @item.nil?
    return 0 if @item.is_a?(RPG::Item)

    param_page_max + enchant_page_max
  end

  #--------------------------------------------------------------------------
  # ○ ページの更新
  #--------------------------------------------------------------------------
  def next_page
    return true if page_max == 0

    @page_index = (@page_index + 1) % page_max
    refresh
    @page_index == 0
  end

  #--------------------------------------------------------------------------
  # ● ウィンドウの非表示
  #--------------------------------------------------------------------------
  def show
    @page_index = 0
    super
  end

  #--------------------------------------------------------------------------
  # ○ リフレッシュ
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    if @item.nil?
      change_color(normal_color, false)
      draw_text(0, 0, contents_width, line_height, "何も選択していません")
      return
    end
    return if page_max == 0
    return if @item.is_a?(RPG::Item)

    method_name = draw_methods[@page_index][:name]
    index = draw_methods[@page_index][:index]
    send(method_name, 0, 0, index)
  end

  #--------------------------------------------------------------------------
  # ● 所持数の描画
  #--------------------------------------------------------------------------
  def draw_possession(x, y)
    rect = Rect.new(0, 0, 304, line_height)
    enable = SceneManager.scene.equip_info_enable
    change_color(normal_color)
    draw_item_name(@item, rect.x, rect.y, enable)
    change_color(normal_color, enable)
    draw_text(rect, format(":%2d", $game_party.item_number(@item)), 2)
  end

  #--------------------------------------------------------------------------
  # ● ボタン説明の描画
  #--------------------------------------------------------------------------
  def draw_button(x, y)
    rect = Rect.new(x, y, contents.width, line_height)
    change_color(system_color)
    draw_text(rect, @page_index + 1 == page_max ? Help.item_info_exit : Help.item_info_change)
    draw_text(rect, "#{@page_index + 1}/#{page_max}", 2)
  end

  #--------------------------------------------------------------------------
  # ● 描画命令メソッド配列の取得
  #--------------------------------------------------------------------------
  def draw_methods
    methods = []
    param_page_max.times { |i| methods.push({ :name => :draw_params, :index => i }) }
    enchant_page_max.times { |i| methods.push({ :name => :draw_enchants, :index => i + param_page_max }) }
    methods.push({ :name => :draw_empty }) if methods.empty?
    methods
  end

  #--------------------------------------------------------------------------
  # ● 効果なしの描画
  #--------------------------------------------------------------------------
  def draw_empty(x, y, index)
    rect = Rect.new(x, y, contents.width, line_height)
    change_color(system_color)
    draw_text(rect, "効果")
    rect.y += line_height + 2
    change_color(normal_color)
    draw_text(rect, "なし")
  end

  #--------------------------------------------------------------------------
  # ● 基礎性能の描画
  #--------------------------------------------------------------------------
  def draw_params(x, y, index)
    rect = Rect.new(x, y, 150, line_height)

    param_names = @item.param_names
    change_color(system_color)
    draw_text(rect, "基礎性能")
    rect.x += 10
    rect.y += line_height + 2

    @item.params.each.with_index do |param, i|
      next if param == 0

      change_color(system_color)
      draw_text(rect, Vocab.param(i))
      change_color(normal_color)
      draw_text(rect, param, 2)
      rect.y += line_height
    end
    param_names.each do |param|
    end
    draw_enchants(x + 320, 0, index)
  end

  #--------------------------------------------------------------------------
  # ● 特殊効果の描画
  #--------------------------------------------------------------------------
  def draw_enchants(x, y, index)
    rect = Rect.new(x, y, 300, line_height)
    range_array = draw_enchant_contents(index)
    enchant_names = @item.enchant_names[range_array[0], range_array[1]]
    change_color(system_color)
    draw_text(rect, "特殊効果")
    rect.x += 10
    rect.y += line_height + 2
    change_color(normal_color)

    while enchant_names && !enchant_names.empty?
      rect.y = y + line_height + 2
      array = enchant_names.shift(NWConst::EquipInfo::STATUS_MAX)
      array.each do |enchant|
        draw_text_plus(rect, enchant)
        rect.y += line_height
      end
      rect.x += 320
    end
    change_color(system_color)
    rect.x = 320
    rect.y = contents.height - line_height
    draw_text(rect, "→次のページ") if page_max - 1 > @page_index
  end

  def draw_enchant_contents(index)
    return [0, NWConst::EquipInfo::STATUS_MAX] if index == 0

    a = draw_enchant_contents(index - 1)
    a[0] = a[1]
    a[1] += NWConst::EquipInfo::STATUS_MAX * 2
    a
  end

  def param_page_max
    1
  end

  def enchant_page_max
    [((@item.enchant_names.size - NWConst::EquipInfo::STATUS_MAX).to_f / NWConst::EquipInfo::STATUS_MAX / 2.0).ceil,
     0].max.to_i
  end
end

class Window_SkillCommand < Window_Command
  #--------------------------------------------------------------------------
  # ● 前回の選択位置を復帰
  #--------------------------------------------------------------------------
  def select_last
    stype_id = @actor.get_last_stype
    select(0)
    select_ext(stype_id)
  end

  #--------------------------------------------------------------------------
  # ● 決定やキャンセルなどのハンドリング処理
  #--------------------------------------------------------------------------
  def process_handling
    return unless open? && active
    return process_swap(-1) if Input.press?(:X) && Input.repeat?(:UP)
    return process_swap(1) if Input.press?(:X) && Input.repeat?(:DOWN)
    return process_clear_swap  if Input.press?(:X) && Input.trigger?(:B)
    return process_ok       if ok_enabled?        && Input.trigger?(:C)
    return process_cancel   if cancel_enabled?    && Input.trigger?(:B)
    return process_pagedown if handle?(:pagedown) && Input.trigger?(:R)
    return process_pageup   if handle?(:pageup)   && Input.trigger?(:L)
    return process_sub      if Input.trigger?(:A)
  end

  #--------------------------------------------------------------------------
  # ● サブキー(Aボタン)が押されたときの処理
  #--------------------------------------------------------------------------
  def process_sub
    Sound.play_ok
    Input.update
    @actor.flip_skill_type_disabled(current_ext)
    refresh
  end

  #--------------------------------------------------------------------------
  # ● 並べ替えの処理
  #--------------------------------------------------------------------------
  def process_swap(plus)
    Input.update
    target = index + plus
    return Sound.play_buzzer unless (0..item_max - 1).include?(target)

    Sound.play_equip
    @actor.swap_stype_sort(@list[index][:ext], @list[target][:ext])
    refresh
    select(target)
  end

  #--------------------------------------------------------------------------
  # ● 並べ替えリセットの処理
  #--------------------------------------------------------------------------
  def process_clear_swap
    Sound.play_equip
    Input.update
    last_ext = current_ext
    @actor.clear_stype_sort
    refresh
    select_ext(last_ext)
  end

  #--------------------------------------------------------------------------
  # ○ コマンドリストの作成
  #--------------------------------------------------------------------------
  def make_command_list
    return unless @actor

    all_skill_types = @actor.skills.collect { |skill| skill.stype_id }.uniq
    all_skill_types.reject! { |stype_id| NWConst::Ability::ABILITY_SKILL_TYPE.include?(stype_id) }
    enable_skill_types = @actor.added_skill_types
    enable_skill_types.reject! { |stype_id| @actor.skill_type_sealed?(stype_id) }

    all_skill_types.select do |stype_id|
      stype_usable?(stype_id)
    end.tap do |stypes|
      break @actor.sorted_stypes(stypes)
    end.each  do |stype_id|
      name = $data_system.skill_types[stype_id]
      add_command(name, :skill, enable_skill_types.include?(stype_id), stype_id)
    end
  end

  #--------------------------------------------------------------------------
  # ● 項目の描画
  #--------------------------------------------------------------------------
  def draw_item(index)
    super(index)
    return unless @actor.skill_type_disabled?(@list[index][:ext])

    change_color(bad_color, command_enabled?(index))
    draw_text(item_rect_for_text(index), "封", 2)
  end

  #--------------------------------------------------------------------------
  # ● 選択項目の有効状態を取得
  #--------------------------------------------------------------------------
  def current_item_enabled?
    true
  end

  #--------------------------------------------------------------------------
  # ● フレーム更新
  #--------------------------------------------------------------------------
  def update
    super
    return unless current_data

    if @skill_window
      @skill_window.stype_unusable = !current_data[:enabled]
      @skill_window.stype_id = current_ext
    end
  end

  #--------------------------------------------------------------------------
  # ● カーソルの移動可能判定
  #--------------------------------------------------------------------------
  def cursor_movable?
    super && !Input.press?(:X)
  end

  #--------------------------------------------------------------------------
  # ● 使用可能なスキルタイプ？（そのタイプのスキルを習得している）
  #--------------------------------------------------------------------------
  def stype_usable?(stype_id)
    @actor.skills.any? { |skill| skill.stype_id == stype_id }
  end
end

class Window_SkillList < Window_Selectable
  #--------------------------------------------------------------------------
  # ● 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_accessor :stype_unusable
  attr_reader :actor

  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  alias nw_toris_initialize initialize
  def initialize(x, y, width, height)
    create_item_cost_window
    nw_toris_initialize(x, y, width, height)
  end

  def create_item_cost_window
    @item_cost_window = Window_ItemCost.new(self)
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新
  #--------------------------------------------------------------------------
  def update
    super
    return unless @item_cost_window

    @item_cost_window.z = z + 100
    @item_cost_window.update
  end

  #--------------------------------------------------------------------------
  # ● ウィンドウのアクティブ化
  #--------------------------------------------------------------------------
  def activate
    super

    @item_cost_window.refresh if @item_cost_window
  end

  #--------------------------------------------------------------------------
  # ● ウィンドウの非アクティブ化
  #--------------------------------------------------------------------------
  def deactivate
    super
    @item_cost_window.hide if @item_cost_window
  end

  #--------------------------------------------------------------------------
  # ● 解放
  #--------------------------------------------------------------------------
  def dispose
    super
    @item_cost_window.dispose if @item_cost_window
  end

  #--------------------------------------------------------------------------
  # ● 項目の選択
  #--------------------------------------------------------------------------
  def select(index)
    super(index)
    @item_cost_window.refresh if @item_cost_window
  end

  #--------------------------------------------------------------------------
  # ● 前回の選択位置を復帰
  #--------------------------------------------------------------------------
  def select_last
    select(0)
    select(@data.index(@actor.get_last_skill(@stype_id)) || 0)
  end
  #--------------------------------------------------------------------------
  # ● アイテムリストの作成
  #--------------------------------------------------------------------------
  alias nw_toris_make_item_list make_item_list
  def make_item_list
    nw_toris_make_item_list
    @item_cost_window.set_size(@data) if @item_cost_window
  end

  #--------------------------------------------------------------------------
  # ● 画面に対するカーソル枠の下端
  #--------------------------------------------------------------------------
  def cursor_y_down
    y + standard_padding + item_rect(index).y + line_height - oy
  end

  #--------------------------------------------------------------------------
  # ○ スキルをリストに含めるかどうか
  #--------------------------------------------------------------------------
  def include?(item)
    item && item.stypes.include?(@stype_id)
  end

  #--------------------------------------------------------------------------
  # ● 選択項目の有効状態を取得
  #--------------------------------------------------------------------------
  def current_item_enabled?
    enable?(@data[index]) && !@stype_unusable
  end

  #--------------------------------------------------------------------------
  # ● アイテム名の描画
  #     enabled : 有効フラグ。false のとき半透明で描画
  #--------------------------------------------------------------------------
  def draw_item_name(item, x, y, enabled = true, width = 236)
    return unless item

    draw_icon(item.icon_index, x, y, enabled)
    color = @stype_unusable ? bad_color : normal_color
    change_color(color, enabled)
    draw_text(x + 24, y, width, line_height, item.name)
  end

  #--------------------------------------------------------------------------
  # ○ スキルの使用コストを描画
  #--------------------------------------------------------------------------
  def draw_skill_cost(rect, skill)
    r = Rect.new.set(rect)
    r.x += rect.width
    i = 0
    draw_cost = proc do |cost, color|
      next unless cost > 0

      i += 1
      if i != 1
        r.x -= text_size("/").width
        change_color(normal_color, enable?(skill))
        draw_text(r, "/", 0)
      end
      cost = cost.give_unit_floor(4) if cost >= 100_000

      r.x -= text_size(cost).width
      change_color(color, enable?(skill))
      draw_text(r, cost, 0)
    end

    draw_cost.call(@actor.skill_gold_cost(skill), gold_cost_color)
    draw_cost.call(@actor.skill_tp_cost(skill), tp_cost_color)
    draw_cost.call(@actor.skill_mp_cost(skill), mp_cost_color)
    draw_cost.call(@actor.skill_hp_cost(skill), hp_cost_color)
  end

  alias h_window_skilllist_enable? enable?
  def enable?(item)
    h_window_skilllist_enable?(item) && (!item.warp_item? || WarpManager.usable?)
  end
end

class Window_SkillStatus < Window_Base
  #--------------------------------------------------------------------------
  # ○ リフレッシュ
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    return unless @actor

    draw_actor_face(@actor, 0, 0)
    draw_actor_simple_status(@actor, 108, 0)
  end
end
class Window_StoneList < Window_ItemList
  def initialize
    super(Graphics.width / 2, fitting_height(2) + fitting_height(1) + fitting_height(5), Graphics.width / 2, Graphics.height - (fitting_height(2) + fitting_height(1) + fitting_height(5)))
    refresh
  end

  #--------------------------------------------------------------------------
  # ● ウィンドウの非アクティブ化
  #--------------------------------------------------------------------------
  def deactive
    unselect
    super
  end

  #--------------------------------------------------------------------------
  # ● アイテムをリストに含めるかどうか
  #--------------------------------------------------------------------------
  def include?(item)
    return true if item.nil?

    item.is_a?(RPG::Item) && item.enchant_stone?
  end

  #--------------------------------------------------------------------------
  # ● 桁数の取得
  #--------------------------------------------------------------------------
  def col_max
    1
  end

  #--------------------------------------------------------------------------
  # ● アイテムを許可状態で表示するかどうか
  #--------------------------------------------------------------------------
  def enable?(item)
    true
  end
end

class Window_AE_Stone_List < Window_StoneList
  def initialize
    super()
    self.x = 0
    self.width = Graphics.width
    hide
  end

  def col_max
    2
  end
end
class Window_Vertical_Command < Window_Command
  def row_max
    page_row_max
  end

  def page_col_max
    2
  end

  def col_max
    [(item_max + row_max - 1) / row_max, 1].max
  end

  def draw_page
    index = top_col * row_max
    max = [(index + page_item_max + 1), item_max].min
    return if (max - index) <= 0

    (max - index).times do |i|
      next if @draw[i + index]

      @draw[i + index] = true
      draw_item(i + index)
    end
  end

  def page_item_max
    page_row_max * page_col_max
  end

  def col
    index / row_max
  end

  def item_rect(index)
    rect = Rect.new
    rect.width = item_width
    rect.height = item_height
    rect.x = index / row_max * (item_width + spacing)
    rect.y = index % row_max * item_height
    rect
  end

  def contents_height
    height - standard_padding * 2
  end

  def contents_width
    [super - super % item_width, (item_width + spacing) * col_max - spacing].max
  end

  def cursor_pagedown
    if top_col + page_col_max < col_max
      self.top_col += page_col_max
      select([@index + page_item_max, item_max - 1].min)
    end
  end

  def cursor_pageup
    if top_col > 0
      self.top_col -= page_col_max
      select([@index - page_item_max, 0].max)
    end
  end

  def ensure_cursor_visible
    self.top_col = col if col < top_col
    self.bottom_col = col if col > bottom_col
  end

  def top_col
    ox / (item_width + spacing)
  end

  def top_col=(col)
    col = 0 if col < 0
    col = col_max - 1 if col > col_max - 1
    self.ox = col * (item_width + spacing)
  end

  def bottom_col
    top_col + page_col_max - 1
  end

  def bottom_col=(col)
    self.top_col = col - (page_col_max - 1)
  end

  def cursor_down(wrap = false)
    select((index + 1) % item_max) if row_max >= 2 && (index < item_max - 1 || (wrap && horizontal?))
  end

  def cursor_up(wrap = false)
    select((index - 1 + item_max) % item_max) if row_max >= 2 && (index > 0 || (wrap && horizontal?))
  end

  def cursor_right(wrap = false)
    select([index + page_row_max, item_max - 1].min) if col + 1 < col_max
  end

  def cursor_left(wrap = false)
    select((index - page_row_max + item_max) % item_max) if index >= page_row_max
  end

  def item_width
    (width - standard_padding * 2 + spacing) / page_col_max - spacing
  end
end