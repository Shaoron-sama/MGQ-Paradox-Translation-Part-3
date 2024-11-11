# =コンフィグ＋
#
#
#
#
# ==更新履歴
#   Date     Version Author Comment
#

#==============================================================================
# ■ NWConst::Config
#==============================================================================
module NWConst::Config
  # 大項目のコンテンツ
  CONTENTS = [
    { :key => :window_tone,  :name => "ウィンドウ色", :sub => false,
      :help => "ウィンドウの色調設定です。" },
    { :key => :sound_volume, :name => "音量設定", :sub => false,
      :help => "ゲーム中の音量設定です。" },
    { :key => :key_text,     :name => "ボタン説明文", :sub => true,
      :help => "表示される操作説明を変更します。\r\n←/→で選択。" },
    { :key => :map_dash,     :name => "ダッシュ反転", :sub => true,
      :help => "【マップ】歩行とダッシュを反転させる設定です。\r\n←/→で選択。" },
    { :key => :map_speed,    :name => "ダッシュ速度", :sub => true,
      :help => "【マップ】ダッシュ速度の設定です。\r\n←/→で選択。" },
    { :key => :bt_skip,      :name => "セリフ・カットイン", :sub => true,
      :help => "【戦闘】セリフとカットインの表示設定です。\r\n←/→で選択。" },
    { :key => :bt_skip_enemy_cutin, :name => "敵カットイン", :sub => true,
      :help => "【戦闘】敵のカットイン表示設定です。\r\n←/→で選択。" },
    {:key => :bt_skip_chain_action_cutin, :name => "スキルチェーンカットイン", :sub => true,
      :help => "【戦闘】チェーンスキルで発動したスキルのカットイン表示設定です。\r\n←/→で選択。"},
    { :key => :bt_auto,      :name => "ログ送り", :sub => true,
      :help => "【戦闘】ログの表示設定です。\r\n←/→で選択。" },
    { :key => :bt_wait,      :name => "戦闘時ウェイト", :sub => true,
      :help => "【戦闘】ウェイトの設定です。\r\n←/→で選択。" },
    { :key => :bt_result,    :name => "勝利結果スキップ", :sub => true,
      :help => "【戦闘】勝利結果の eval<Vocab.key_x>ボタン でのスキップ速度設定です。\r\n←/→で選択。" },
    { :key => :bt_stype,     :name => "スキルタイプ表示", :sub => true,
      :help => "【戦闘】スキルタイプの表示設定です。\r\n←/→で選択。" },
    { :key => :bt_regenerate, :name => "ターン回復メッセージカット", :sub => true,
      :help => "【戦闘】行動終了時の回復のメッセージカットの設定です。\r\n←/→で選択。" },
    { :key => :bt_show_actor_status, :name => "戦闘時簡易状態ウィンドウ", :sub => true,
      :help => "【戦闘】行動時の簡易状態ウィンドウの表示設定です。\r\n←/→で選択。" },
    { :key => :ls_auto,      :name => "オートモード", :sub => true,
      :help => "【敗北イベント】オートモードに関する設定です。\r\n←/→で選択。" },
    { :key => :ls_wait,      :name => "オート速度", :sub => true,
      :help => "【敗北イベント】オートモードの速度設定です。\r\n←/→で選択。" },
    { :key => :ls_predation, :name => "捕食シーンカット", :sub => true,
      :help => "【敗北イベント】捕食シーンカットの設定です。\r\n←/→で選択。" },
    { :key => :ls_skip,      :name => "敗北イベントスキップ", :sub => true,
      :help => "敗北イベントのスキップ関連設定です。\r\n←/→で選択。" },
    { :key => :default,      :name => "初期化", :sub => false,
      :help => "初期値に戻します。" },
    { :key => :return,       :name => "戻る", :sub => false,
      :help => "元の画面に戻ります。" }
  ]
  # 小項目のコンテンツ
  DATA = {
    :map_dash => [false, true],
    :map_speed => [0, 1, 2],
    :key_text => [:gamepad, :keyboard],
    :bt_skip => [false, true],
    :bt_skip_enemy_cutin => [false, true],
    :bt_skip_chain_action_cutin => [false, true],
    :bt_auto => [false, true],
    :bt_wait => [100, 50, 25],
    :bt_result => [0, 1, 2, nil],
    :bt_stype => [false, true],
    :bt_regenerate => [false, true],
    :bt_show_actor_status => [false, true],
    :ls_auto => [false, true],
    :ls_wait => [10, 5, 3],
    :ls_predation => [false, true],
    :ls_skip => [0, 1, 2]
  }
  # 色調ゲージ用の色データ
  TONE_COLOR = {
    :tone_r => Color.new(255, 0, 0),
    :tone_g => Color.new(0, 255, 0),
    :tone_b => Color.new(0, 0, 255)
  }
  # 音量ゲージ用データ
  SOUND_GAUGE = {
    :volume_bgm => { :name => "BGM", :color => Color.new(255, 32, 32) },
    :volume_bgs => { :name => "BGS", :color => Color.new(255, 192, 0) },
    :volume_me => { :name => " ME", :color => Color.new(0, 192, 255) },
    :volume_se => { :name => " SE", :color => Color.new(32, 32, 255) }
  }
  # 小項目のコンテンツ文章
  DATA_TEXT = {
    :key_text => {
      :gamepad => { :name => "ゲームパッド", :help => "ゲームパッド準拠で表示します。" },
      :keyboard => { :name => "キーボード", :help => "キーボード準拠で表示します。" }
    },
    :map_dash => {
      false => { :name => "反転させない", :help => "デフォルトで歩行状態です。" },
      true => { :name => "反転させる", :help => "デフォルトでダッシュ状態です。" }
    },
    :map_speed => {
      0 => { :name => "基本", :help => "通常のダッシュ速度です。" },
      1 => { :name => "高速", :help => "一段階速いダッシュ速度です。" },
      2 => { :name => "最速", :help => "二段階速いダッシュ速度です。" }
    },
    :bt_skip => {
      false => { :name => "表示", :help => "セリフとカットインを表示します。" },
      true => { :name => "省略", :help => "セリフとカットインを省略します。" }
    },
    :bt_skip_enemy_cutin => {
      false => { :name => "表示", :help => "敵カットインを表示します。" },
      true => { :name => "省略", :help => "敵カットインを省略します。" }
    },
    :bt_skip_chain_action_cutin => {
      false => { :name => "表示", :help => "カットインを表示します。" },
      true => { :name => "省略", :help => "カットインを省略します。" }
    },
    :bt_auto => {
      false => { :name => "手動", :help => "戦闘ログとメッセージを手動で次に送ります。" },
      true => { :name => "自動", :help => "戦闘ログとメッセージを自動で次に送ります。" }
    },
    :bt_wait => {
      100 => { :name => "基本", :help => "戦闘中ウェイトをデフォルトにします。" },
      50 => { :name => "高速", :help => "戦闘中ウェイトを1/2にします。" },
      25 => { :name => "最速", :help => "戦闘中ウェイトを1/4にします。" }
    },
    :bt_result => {
      0 => { :name => "スキップしない", :help => "スキップしません。" },
      1 => { :name => "低速スキップ", :help => "１文字ごとに少し待機してからスキップします。" },
      2 => { :name => "高速スキップ", :help => "行ごとかページごとに待機してからスキップします。" },
      nil => { :name => "瞬間スキップ", :help => "一瞬でスキップします。" }
    },
    :bt_stype => {
      true => { :name => "設定通り", :help => "非表示設定にしているスキルタイプを全て省略します。" },
      false => { :name => "全表示", :help => "非表示設定にしているスキルタイプを全て表示します。" }
    },
    :bt_regenerate => {
      false => { :name => "オフ", :help => "再生率のメッセージをカットしません。" },
      true => { :name => "オン", :help => "再生率のメッセージをカットします。" }
    },
    :bt_show_actor_status => {
      false => { :name => "非表示", :help => "簡易状態ウィンドウを表示しません" },
      true => { :name => "表示", :help => "簡易状態ウィンドウを表示します。" }
    },
    :ls_auto => {
      false => { :name => "オフ", :help => "オートモードをオフにしてイベント開始します。" },
      true => { :name => "オン", :help => "オートモードをオンにしてイベント開始します。" }
    },
    :ls_wait => {
      10 => { :name => "低速", :help => "敗北イベント中ウェイトを2倍にします。" },
      5 => { :name => "基本", :help => "敗北イベント中ウェイトをデフォルトにします。" },
      3 => { :name => "高速", :help => "敗北イベント中ウェイトを1/2にします。" }
    },
    :ls_predation => {
      false => { :name => "オフ", :help => "捕食シーンをカットしません。" },
      true => { :name => "オン", :help => "捕食シーンをカットします。" }
    },
    :ls_skip => {
      0 => { :name => "毎回見る", :help => "毎回、敗北シーンを全て見ます。" },
      1 => { :name => "既読スキップ", :help => "一度見た敗北シーンをスキップします。" },
      2 => { :name => "毎回確認", :help => "敗北シーンを見るか事前確認します。" }
    }
  }
  # 規定値
  DEFAULT = {
    :tone_r => -34,
    :tone_g => 0,
    :tone_b => 68,
    :volume_bgm => 70,
    :volume_bgs => 70,
    :volume_se => 70,
    :volume_me => 70,
    :key_text => :gamepad,
    :map_dash => false,
    :map_speed => 0,
    :bt_skip => false,
    :bt_skip_enemy_cutin => false,
    :bt_skip_chain_action_cutin => false,
    :bt_auto => false,
    :bt_wait => 100,
    :bt_result => nil,
    :bt_stype => true,
    :bt_regenerate => false,
    :bt_show_actor_status => true,
    :ls_auto => false,
    :ls_wait => 5,
    :ls_predation => false,
    :ls_skip => 0
  }
end

#==============================================================================
# ■ Audio
#==============================================================================
class << Audio
  #--------------------------------------------------------------------------
  # ○ BGM再生
  #--------------------------------------------------------------------------
  alias nw_config_bgm_play bgm_play
  def bgm_play(filename, volume = 100, pitch = 100, pos = 0)
    v = (volume * ($game_system.conf[:volume_bgm].to_f / 100)).ceil
    nw_config_bgm_play(filename, v, pitch, pos)
  end
  #--------------------------------------------------------------------------
  # ○ BGS再生
  #--------------------------------------------------------------------------
  alias nw_config_bgs_play bgs_play
  def bgs_play(filename, volume = 100, pitch = 100, pos = 0)
    v = (volume * ($game_system.conf[:volume_bgs].to_f / 100)).ceil
    nw_config_bgs_play(filename, v, pitch, pos)
  end
  #--------------------------------------------------------------------------
  # ○ ME再生
  #--------------------------------------------------------------------------
  alias nw_config_me_play me_play
  def me_play(filename, volume = 100, pitch = 100)
    v = (volume * ($game_system.conf[:volume_me].to_f / 100)).ceil
    nw_config_me_play(filename, v, pitch)
  end
  #--------------------------------------------------------------------------
  # ○ SE再生
  #--------------------------------------------------------------------------
  alias nw_config_se_play se_play
  def se_play(filename, volume = 100, pitch = 100)
    v = (volume * ($game_system.conf[:volume_se].to_f / 100)).ceil
    nw_config_se_play(filename, v, pitch)
  end
end

#==============================================================================
# ■ Game_System
#----------------------------------------------------------------------------
# コンフィグデータはHashで扱います。
#==============================================================================
class Game_System
  #--------------------------------------------------------------------------
  # ● コンフィグ初期化
  #--------------------------------------------------------------------------
  def init_config
    @data_config = NWConst::Config::DEFAULT.dup
  end

  def update_config
    @data_config = NWConst::Config::DEFAULT.dup.merge(@data_config)
  end
  #--------------------------------------------------------------------------
  # ● 色調コンフィグ初期化
  #--------------------------------------------------------------------------
  def init_tone_config
    @data_config[:tone_r] = NWConst::Config::DEFAULT[:tone_r]
    @data_config[:tone_g] = NWConst::Config::DEFAULT[:tone_g]
    @data_config[:tone_b] = NWConst::Config::DEFAULT[:tone_b]
  end

  #--------------------------------------------------------------------------
  # ● 音量コンフィグ初期化
  #--------------------------------------------------------------------------
  def init_sound_config
    @data_config[:volume_bgm] = NWConst::Config::DEFAULT[:volume_bgm]
    @data_config[:volume_bgs] = NWConst::Config::DEFAULT[:volume_bgs]
    @data_config[:volume_me]  = NWConst::Config::DEFAULT[:volume_me]
    @data_config[:volume_se]  = NWConst::Config::DEFAULT[:volume_se]
  end

  #--------------------------------------------------------------------------
  # ● インスタンス変数data_configのゲッター
  #--------------------------------------------------------------------------
  def conf
    @data_config
  end
end

#==============================================================================
# ■ Game_Player
#==============================================================================
class Game_Player < Game_Character
  #--------------------------------------------------------------------------
  # ● 移動速度の取得（ダッシュを考慮）【オーバーライド】
  #--------------------------------------------------------------------------
  def real_move_speed
    spd = 1 + $game_system.conf[:map_speed].to_i
    @move_speed + (dash? ? spd : 0)
  end
  #--------------------------------------------------------------------------
  # ○ ダッシュ状態判定
  #--------------------------------------------------------------------------
  alias nw_config_dash? dash?
  def dash?
    (nw_config_dash? ^ $game_system.conf[:map_dash]) && vehicle.nil?
  end
end

#==============================================================================
# ■ Sprite_Battler
#==============================================================================
class Sprite_Battler < Sprite_Base
  #--------------------------------------------------------------------------
  # ○ エフェクトの開始
  #--------------------------------------------------------------------------
  def start_effect(effect_type)
    @effect_type = effect_type
    speed = $game_system.conf[:bt_wait].to_f / 100.0
    case @effect_type
    when :appear
      @effect_duration = Integer(16 * speed)
      @battler_visible = true
    when :disappear
      @effect_duration = Integer(32 * speed)
      @battler_visible = false
    when :whiten
      @effect_duration = Integer(16 * speed)
      @battler_visible = true
    when :blink
      @effect_duration = Integer(20 * speed)
      @battler_visible = true
    when :collapse
      @effect_duration = Integer(48 * speed)
      @battler_visible = false
    when :boss_collapse
      @effect_duration = Integer(bitmap.height * speed)
      @battler_visible = false
    when :instant_collapse
      @effect_duration = Integer(16 * speed)
      @battler_visible = false
    end
    revert_to_normal
  end
end

#==============================================================================
# ■ Window_BattleMessage
#==============================================================================
class Window_BattleMessage < Window_Message
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize
    super
    self.opacity = 0
  end

  #--------------------------------------------------------------------------
  # ● ウィンドウを開く
  #--------------------------------------------------------------------------
  def open
    self.openness = 255
  end

  #--------------------------------------------------------------------------
  # ● ウィンドウを閉じる
  #--------------------------------------------------------------------------
  def close
    self.openness = 0
  end

  #--------------------------------------------------------------------------
  # ● 入力待ち処理
  #--------------------------------------------------------------------------
  def input_pause
    if $game_system.conf[:bt_auto]
      speed = $game_system.conf[:bt_wait].to_f * 0.01
      wait(Integer(30 * speed))
    else
      super
    end
  end
end

#==============================================================================
# ■ Window_Config
#==============================================================================
class Window_Config < Window_Selectable
  include NWConst::Config
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #-------------------------------------------------------------------------
  def initialize
    super(0, 72, Graphics.width, Graphics.height - 72)
    refresh
  end

  #--------------------------------------------------------------------------
  # ● 項目数の取得
  #--------------------------------------------------------------------------
  def item_max
    CONTENTS.size
  end

  #--------------------------------------------------------------------------
  # ● 項目のキー値を取得
  #--------------------------------------------------------------------------
  def key(index)
    CONTENTS[index][:key]
  end

  #--------------------------------------------------------------------------
  # ● 項目の名前を取得
  #--------------------------------------------------------------------------
  def name(index)
    CONTENTS[index][:name]
  end

  #--------------------------------------------------------------------------
  # ● 副項目の名前を取得
  #--------------------------------------------------------------------------
  def sub_name(index)
    DATA_TEXT[key(index)][$game_system.conf[key(index)]][:name]
  end

  #--------------------------------------------------------------------------
  # ● 項目のヘルプ文章を取得
  #--------------------------------------------------------------------------
  def help_text(index)
    text = CONTENTS[index][:help]
    text += "\r\n#{sub_help_text(index)}" if sub_exist?(index)
    text.gsub(/eval<(\S+)>/) { eval($1) }
  end

  #--------------------------------------------------------------------------
  # ● 副項目のヘルプ文章を取得
  #--------------------------------------------------------------------------
  def sub_help_text(index)
    DATA_TEXT[key(index)][$game_system.conf[key(index)]][:help]
  end

  #--------------------------------------------------------------------------
  # ● 項目にサブ項目が存在する？
  #--------------------------------------------------------------------------
  def sub_exist?(index)
    CONTENTS[index][:sub]
  end

  #--------------------------------------------------------------------------
  # ● 項目の幅を取得
  #--------------------------------------------------------------------------
  def item_width
    240
  end

  #--------------------------------------------------------------------------
  # ● 副項目の幅を取得
  #--------------------------------------------------------------------------
  def item_sub_width
    160
  end

  #--------------------------------------------------------------------------
  # ● 項目を描画する矩形の取得
  #--------------------------------------------------------------------------
  def item_rect(index)
    rect = Rect.new
    rect.width = item_width
    rect.height = item_height
    rect.x = 80
    rect.y = index * item_height
    rect
  end

  #--------------------------------------------------------------------------
  # ● 副項目を描画する矩形の取得
  #--------------------------------------------------------------------------
  def item_sub_rect(index)
    rect = Rect.new
    rect.width = item_width
    rect.height = item_height
    rect.x = 340
    rect.y = index * item_height
    rect
  end

  #--------------------------------------------------------------------------
  # ● カーソルを右に移動
  #--------------------------------------------------------------------------
  def cursor_right(wrap = false)
    return unless sub_exist?(index)

    k = key(index)
    index = DATA[k].index($game_system.conf[k])
    index = (index + 1) % DATA[k].size
    $game_system.conf[k] = DATA[k][index]
    Sound.play_cursor
    refresh
  end

  #--------------------------------------------------------------------------
  # ● カーソルを左に移動
  #--------------------------------------------------------------------------
  def cursor_left(wrap = false)
    return unless sub_exist?(index)

    k = key(index)
    index = DATA[k].index($game_system.conf[k])
    index -= 1
    $game_system.conf[k] = DATA[k][index]
    Sound.play_cursor
    refresh
  end

  #--------------------------------------------------------------------------
  # ● 決定処理の有効状態を取得
  #--------------------------------------------------------------------------
  def ok_enabled?
    !sub_exist?(index)
  end

  #--------------------------------------------------------------------------
  # ● 決定ボタンが押されたときの処理
  #--------------------------------------------------------------------------
  def process_ok
    Sound.play_ok
    Input.update
    call_handler(key(index))
  end

  #--------------------------------------------------------------------------
  # ● 項目の描画
  #--------------------------------------------------------------------------
  def draw_item(index)
    rect = item_rect(index)
    rect.x += 20
    rect.width -= 20
    draw_text(rect, name(index))
    return unless sub_exist?(index)

    value = $game_system.conf[key(index)]
    draw_text(item_sub_rect(index), DATA_TEXT[key(index)][value][:name])
  end

  #--------------------------------------------------------------------------
  # ● ヘルプウィンドウの更新
  #--------------------------------------------------------------------------
  def update_help
    super
    @help_window.set_text(help_text(index))
  end

  #--------------------------------------------------------------------------
  # ● リフレッシュ
  #--------------------------------------------------------------------------
  def refresh
    super
    call_update_help
  end
end

#==============================================================================
# ■ Window_ToneConfig
#==============================================================================
class Window_ToneConfig < Window_Selectable
  include NWConst::Config
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #-------------------------------------------------------------------------
  def initialize
    super(160, 120, 320, fitting_height(5))
    refresh
  end

  #--------------------------------------------------------------------------
  # ● 項目数の取得
  #--------------------------------------------------------------------------
  def item_max
    5
  end

  #--------------------------------------------------------------------------
  # ● カーソルを右に移動
  #--------------------------------------------------------------------------
  def cursor_right(wrap = false)
    return unless (0..2).include?(index)

    key = [:tone_r, :tone_g, :tone_b][index]
    return if $game_system.conf[key] == 255

    $game_system.conf[key] = [$game_system.conf[key] + 5, 255].min
    Sound.play_cursor
    refresh
  end

  #--------------------------------------------------------------------------
  # ● カーソルを左に移動
  #--------------------------------------------------------------------------
  def cursor_left(wrap = false)
    return unless (0..2).include?(index)

    key = [:tone_r, :tone_g, :tone_b][index]
    return if $game_system.conf[key] == -255

    $game_system.conf[key] = [$game_system.conf[key] - 5, -255].max
    Sound.play_cursor
    refresh
  end

  #--------------------------------------------------------------------------
  # ● カーソルを 1 ページ後ろに移動
  #--------------------------------------------------------------------------
  def cursor_pagedown
    return unless (0..2).include?(index)

    key = [:tone_r, :tone_g, :tone_b][index]
    return if $game_system.conf[key] == 255

    $game_system.conf[key] = [$game_system.conf[key] + 50, 255].min
    Sound.play_cursor
    refresh
  end

  #--------------------------------------------------------------------------
  # ● カーソルを 1 ページ前に移動
  #--------------------------------------------------------------------------
  def cursor_pageup
    return unless (0..2).include?(index)

    key = [:tone_r, :tone_g, :tone_b][index]
    return if $game_system.conf[key] == -255

    $game_system.conf[key] = [$game_system.conf[key] - 50, -255].max
    Sound.play_cursor
    refresh
  end

  #--------------------------------------------------------------------------
  # ● 決定処理の有効状態を取得
  #--------------------------------------------------------------------------
  def ok_enabled?
    !(0..2).include?(index)
  end

  #--------------------------------------------------------------------------
  # ● 決定ボタンが押されたときの処理
  #--------------------------------------------------------------------------
  def process_ok
    Sound.play_ok
    Input.update
    case index
    when 3 then call_handler(:default)
    when 4 then call_handler(:return)
    end
  end

  #--------------------------------------------------------------------------
  # ● 項目の描画
  #--------------------------------------------------------------------------
  def draw_item(index)
    rect = item_rect(index)
    case index
    when 0..2
      draw_tone_gauge(rect, [:tone_r, :tone_g, :tone_b][index])
    when 3
      draw_text(rect, "初期化", 1)
    when 4
      draw_text(rect, "戻る", 1)
    end
  end

  #--------------------------------------------------------------------------
  # ● ゲージ項目の描画
  #--------------------------------------------------------------------------
  def draw_tone_gauge(rect, key)
    color1 = gauge_back_color
    color2 = TONE_COLOR[key]
    tone   = $game_system.conf[key]
    rate   = (tone + 255) * 0.002
    draw_gauge(rect.x, rect.y, rect.width, rate, color1, color2)
  end

  #--------------------------------------------------------------------------
  # ● ヘルプウィンドウの更新
  #--------------------------------------------------------------------------
  def update_help
    super
    @help_window.set_text(Help.config_tone[index])
  end

  #--------------------------------------------------------------------------
  # ● リフレッシュ
  #--------------------------------------------------------------------------
  def refresh
    super
    call_update_help
    call_handler(:refresh) if handle?(:refresh)
  end
end

#==============================================================================
# ■ Window_SoundConfig
#==============================================================================
class Window_SoundConfig < Window_Selectable
  include NWConst::Config
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #-------------------------------------------------------------------------
  def initialize
    super(160, 120, 320, fitting_height(6))
    refresh
  end

  #--------------------------------------------------------------------------
  # ● 項目数の取得
  #--------------------------------------------------------------------------
  def item_max
    6
  end

  #--------------------------------------------------------------------------
  # ● カーソルを右に移動
  #--------------------------------------------------------------------------
  def cursor_right(wrap = false)
    return unless (0..3).include?(index)

    key = [:volume_bgm, :volume_bgs, :volume_me, :volume_se][index]
    return if $game_system.conf[key] == 100

    $game_system.conf[key] += 1
    Sound.play_cursor
    refresh
  end

  #--------------------------------------------------------------------------
  # ● カーソルを左に移動
  #--------------------------------------------------------------------------
  def cursor_left(wrap = false)
    return unless (0..3).include?(index)

    key = [:volume_bgm, :volume_bgs, :volume_me, :volume_se][index]
    return if $game_system.conf[key] == 0

    $game_system.conf[key] -= 1
    Sound.play_cursor
    refresh
  end

  #--------------------------------------------------------------------------
  # ● カーソルを 1 ページ後ろに移動
  #--------------------------------------------------------------------------
  def cursor_pagedown
    return unless (0..3).include?(index)

    key = [:volume_bgm, :volume_bgs, :volume_me, :volume_se][index]
    return if $game_system.conf[key] == 100

    $game_system.conf[key] = [$game_system.conf[key] + 10, 100].min
    Sound.play_cursor
    refresh
  end

  #--------------------------------------------------------------------------
  # ● カーソルを 1 ページ前に移動
  #--------------------------------------------------------------------------
  def cursor_pageup
    return unless (0..3).include?(index)

    key = [:volume_bgm, :volume_bgs, :volume_me, :volume_se][index]
    return if $game_system.conf[key] == 0

    $game_system.conf[key] = [$game_system.conf[key] - 10, 0].max
    Sound.play_cursor
    refresh
  end

  #--------------------------------------------------------------------------
  # ● 決定処理の有効状態を取得
  #--------------------------------------------------------------------------
  def ok_enabled?
    !(0..3).include?(index)
  end

  #--------------------------------------------------------------------------
  # ● 決定ボタンが押されたときの処理
  #--------------------------------------------------------------------------
  def process_ok
    Sound.play_ok
    Input.update
    case index
    when 4 then call_handler(:default)
    when 5 then call_handler(:return)
    end
  end

  #--------------------------------------------------------------------------
  # ● 項目の描画
  #--------------------------------------------------------------------------
  def draw_item(index)
    rect = item_rect(index)
    case index
    when 0..3
      draw_tone_gauge(rect, [:volume_bgm, :volume_bgs, :volume_me, :volume_se][index])
    when 4
      draw_text(rect, "初期化", 1)
    when 5
      draw_text(rect, "戻る", 1)
    end
  end

  #--------------------------------------------------------------------------
  # ● ゲージ項目の描画
  #--------------------------------------------------------------------------
  def draw_tone_gauge(rect, key)
    color1 = gauge_back_color
    color2 = SOUND_GAUGE[key][:color]
    name   = SOUND_GAUGE[key][:name]
    tone   = $game_system.conf[key]
    draw_gauge(rect.x + 40, rect.y, rect.width - 40, tone * 0.01, color1, color2)
    draw_text(rect, name)
  end

  #--------------------------------------------------------------------------
  # ● ヘルプウィンドウの更新
  #--------------------------------------------------------------------------
  def update_help
    super
    @help_window.set_text(Help.config_sound[index])
  end

  #--------------------------------------------------------------------------
  # ● リフレッシュ
  #--------------------------------------------------------------------------
  def refresh
    super
    call_update_help
  end
end

#==============================================================================
# ■ Scene_Config
#==============================================================================
class Scene_Config < Scene_MenuBase
  include NWConst::Config
  #--------------------------------------------------------------------------
  # ● 開始処理
  #--------------------------------------------------------------------------
  def start
    super
    create_help_window
    create_config_window
    create_tone_config_window
    create_sound_config_window
  end

  #--------------------------------------------------------------------------
  # ● コンフィグウィンドウの作成
  #--------------------------------------------------------------------------
  def create_config_window
    @config_window = Window_Config.new
    @config_window.help_window = @help_window
    @config_window.viewport = @viewport
    @config_window.activate
    @config_window.select(0)
    @config_window.set_handler(:window_tone, method(:start_tone_config))
    @config_window.set_handler(:sound_volume, method(:start_sound_config))
    @config_window.set_handler(:default, method(:set_default))
    @config_window.set_handler(:return, method(:return_scene))
    @config_window.set_handler(:cancel, method(:return_scene))
  end

  #--------------------------------------------------------------------------
  # ● 色調コンフィグの開始
  #--------------------------------------------------------------------------
  def start_tone_config
    @config_window.deactivate
    @tone_config_window.activate.show
    @tone_config_window.select(0)
  end

  #--------------------------------------------------------------------------
  # ● 音量コンフィグの開始
  #--------------------------------------------------------------------------
  def start_sound_config
    @config_window.deactivate
    @sound_config_window.activate.show
    @sound_config_window.select(0)
  end

  #--------------------------------------------------------------------------
  # ● デフォルト値に設定
  #--------------------------------------------------------------------------
  def set_default
    $game_system.init_config
    all_window_refresh
    tone_refresh
    sound_volume_refresh
  end

  #--------------------------------------------------------------------------
  # ● 色調コンフィグウィンドウの作成
  #--------------------------------------------------------------------------
  def create_tone_config_window
    @tone_config_window = Window_ToneConfig.new
    @tone_config_window.help_window = @help_window
    @tone_config_window.viewport = @viewport
    @tone_config_window.deactivate.hide
    @tone_config_window.set_handler(:default, method(:set_tone_default))
    @tone_config_window.set_handler(:return, method(:end_tone_config))
    @tone_config_window.set_handler(:cancel, method(:end_tone_config))
    @tone_config_window.set_handler(:refresh, method(:tone_refresh))
  end

  #--------------------------------------------------------------------------
  # ● 色調値をデフォルトに設定
  #--------------------------------------------------------------------------
  def set_tone_default
    $game_system.init_tone_config
    all_window_refresh
  end

  #--------------------------------------------------------------------------
  # ● 色調のリフレッシュ
  #--------------------------------------------------------------------------
  def tone_refresh
    r = $game_system.conf[:tone_r]
    g = $game_system.conf[:tone_g]
    b = $game_system.conf[:tone_b]
    $game_system.window_tone = Tone.new(r, g, b)
  end

  #--------------------------------------------------------------------------
  # ● 色調コンフィグを終える
  #--------------------------------------------------------------------------
  def end_tone_config
    @tone_config_window.deactivate.hide
    @config_window.activate
    tone_refresh
  end

  #--------------------------------------------------------------------------
  # ● 音声コンフィグウィンドウの作成
  #--------------------------------------------------------------------------
  def create_sound_config_window
    @sound_config_window = Window_SoundConfig.new
    @sound_config_window.help_window = @help_window
    @sound_config_window.viewport = @viewport
    @sound_config_window.deactivate.hide
    @sound_config_window.set_handler(:default, method(:set_sound_default))
    @sound_config_window.set_handler(:return, method(:end_sound_config))
    @sound_config_window.set_handler(:cancel, method(:end_sound_config))
  end

  #--------------------------------------------------------------------------
  # ● 音量をデフォルトに設定
  #--------------------------------------------------------------------------
  def set_sound_default
    $game_system.init_sound_config
    all_window_refresh
  end

  #--------------------------------------------------------------------------
  # ● 音量のリフレッシュ
  #--------------------------------------------------------------------------
  def sound_volume_refresh
    bgm = RPG::BGM.last
    bgs = RPG::BGS.last
    RPG::BGM.stop
    RPG::BGS.stop
    bgm.replay
    bgs.replay
  end

  #--------------------------------------------------------------------------
  # ● 音量コンフィグを終える
  #--------------------------------------------------------------------------
  def end_sound_config
    @sound_config_window.deactivate.hide
    @config_window.activate
    sound_volume_refresh
  end

  #--------------------------------------------------------------------------
  # ● 全てのウィンドウをリフレッシュ
  #--------------------------------------------------------------------------
  def all_window_refresh
    @help_window.refresh
    @config_window.refresh
    @tone_config_window.refresh
    @sound_config_window.refresh
  end
end
