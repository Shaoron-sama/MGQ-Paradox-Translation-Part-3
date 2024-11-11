# =基盤システム/エンチャント名
#
#
#
#
# ==更新履歴
#   Date     Version Author Comment
# ==15/09/03 2.0.2   トリス 統合J～U Q T
# ==17/05/16 2.0.4   トリス 統合V～W V
# ==17/09/21 2.2.0   ひまわり　enchant用調整

#==============================================================================
# ■ RPG::BaseItem
#==============================================================================
module RPG
  class EquipItem
    def enchant_names
      s = socket? ? [socket_name] : []
      s + super
    end
  end

  class BaseItem
    #--------------------------------------------------------------------------
    # ● エンチャント名配列の取得
    #--------------------------------------------------------------------------
    def enchant_names
      if enchant_item?
        base_fts, enchant_fts = features.partition { |ft| ft.enchant_id == -1 }
        enchants_fts = enchant_fts.group_by { |feature| feature.enchant_id }.values
        get_enchant_names(base_fts) + enchants_fts.map { |fts| get_enchant_names(fts) }.flatten
      else
        get_enchant_names(features)
      end
    end

    def get_enchant_names(fts)
      names = []
      dummy = nil

      fts.sort_by { |ft| [-ft.priority, ft.code, ft.data_id] }.each do |ft|
        method_name = enchant_method_table[ft.code]
        if method_name == :dummy_enchant_name
          dummy ||= []
          dummy += send(method_name, ft)
        elsif method_name
          data = send(method_name, ft)
          names.push(data) if data
        end
      end
      names = dummy if dummy
      names.flatten.compact
    end

    def enchant_method_table
      {
        FEATURE_ELEMENT_RATE => :element_rate_name,
        FEATURE_DEBUFF_RATE => :debuff_rate_name,
        FEATURE_STATE_RATE => :state_rate_name,
        FEATURE_STATE_RESIST => :state_resist_name,
        FEATURE_PARAM => :param_name,
        FEATURE_XPARAM => :xparam_name,
        FEATURE_XPARAM_EX => :xparam_name,
        FEATURE_SPARAM => :sparam_name,
        FEATURE_ATK_ELEMENT => :atk_element_name,
        FEATURE_ATK_STATE => :atk_state_name,
        FEATURE_ATK_SPEED => :atk_speed_name,
        FEATURE_ATK_TIMES => :atk_times_name,
        FEATURE_STYPE_ADD => :stype_add_name,
        FEATURE_STYPE_SEAL => :stype_seal_name,
        FEATURE_EQUIP_WTYPE => :equip_wtype_name,
        FEATURE_EQUIP_ATYPE => :equip_atype_name,
        FEATURE_EQUIP_FIX => :equip_fix_name,
        FEATURE_EQUIP_SEAL => :equip_seal_name,
        FEATURE_SLOT_TYPE => :slot_type_name,
        FEATURE_ACTION_PLUS => :action_plus_name,
        FEATURE_SPECIAL_FLAG => :special_flag_name,
        FEATURE_COLLAPSE_TYPE => :collaplse_type_name,
        FEATURE_PARTY_ABILITY => :party_ability_name,
        FEATURE_XPARAM_EX => :xparam_ex_name,
        FEATURE_PARTY_EX_ABILITY => :party_ex_ability_name,
        FEATURE_BATTLER_ABILITY => :battler_ability_name,
        FEATURE_MULTI_BOOSTER => :multi_booster_name,
        FEATURE_DUMMY_ENCHANT => :dummy_enchant_name,
        FEATURE_TERRAIN_BOOSTER => :terrain_booster_name,
        FEATURE_EQUIP_MASTERY => :equip_mastery_name,
        FEATURE_ELEMENT_DRAIN => :element_drain_name,
        FEATURE_ADD_DUMMY_ENCHANT => :dummy_enchant_name,
        FEATURE_BLOCK_RATE => :block_rate_name
      }
    end

    #--------------------------------------------------------------------------
    # ● ソケット数文字列の取得
    #--------------------------------------------------------------------------
    def socket_name
      "ソケット数:#{socket_num}"
    end

    #--------------------------------------------------------------------------
    # ● 属性有効度名の取得
    #--------------------------------------------------------------------------
    def element_rate_name(ft)
      name = $data_system.elements[ft.data_id]
      rate = (ft.value * 100.0).to_i - 100
      "#{name}属性#{0 < rate ? '弱点' : '耐性'}#{rate.abs}%"
    end

    #--------------------------------------------------------------------------
    # ● 弱体有効度名の取得
    #--------------------------------------------------------------------------
    def debuff_rate_name(ft)
      name = Vocab.param(ft.data_id)
      rate = (ft.value * 100.0).to_i - 100
      "#{name}低下#{0 < rate ? '弱点' : '耐性'}"
    end

    #--------------------------------------------------------------------------
    # ● ステート有効度名の取得
    #--------------------------------------------------------------------------
    def state_rate_name(ft)
      name = $data_states[ft.data_id].name
      rate = (ft.value * 100.0).to_i - 100
      "#{name}#{0 < rate ? '弱点' : '耐性'}#{rate.abs}%"
    end

    #--------------------------------------------------------------------------
    # ● ステート無効化名の取得
    #--------------------------------------------------------------------------
    def state_resist_name(ft)
      name = $data_states[ft.data_id].name
      "#{name}無効"
    end

    #--------------------------------------------------------------------------
    # ● 通常能力補正名の取得
    #--------------------------------------------------------------------------
    def param_name(ft)
      name = Vocab.param(ft.data_id)
      rate = (ft.value * 100.0).to_i
      "基本#{name}補正#{rate}%"
    end

    #--------------------------------------------------------------------------
    # ● 追加能力補正名の取得
    #--------------------------------------------------------------------------
    def xparam_name(ft)
      xparam_name_table = [
        "命中率",
        "回避率",
        "会心率",
        "会心回避率",
        "魔法回避率",
        "魔法反射率",
        "反撃率",
        "ターンHP回復",
        "ターンMP回復",
        "ターンSP回復"
      ]
      name = xparam_name_table[ft.data_id]
      rate = (ft.value * 100.0).to_i
      case ft.data_id
      when 0
        "#{name}アップ#{rate}%"
      else
        "#{name}#{rate}%"
      end
    end

    #--------------------------------------------------------------------------
    # ● 特殊能力補正名の取得
    #--------------------------------------------------------------------------
    def sparam_name(ft)
      sparam_name_table = [
        "狙われ率",
        "防御効果",
        "回復力",
        "アイテム効果",
        "MP消費量",
        "SPチャージ",
        "物理ダメージ",
        "魔法ダメージ",
        "床ダメージ",
        "経験値"
      ]
      name = sparam_name_table[ft.data_id]
      rate = (ft.value * 100.0).to_i - 100
      "#{name}#{0 < rate ? 'アップ' : 'ダウン'}"
    end

    #--------------------------------------------------------------------------
    # ● 攻撃時属性名の取得
    #--------------------------------------------------------------------------
    def atk_element_name(ft)
      return nil unless (2..37).include?(ft.data_id)

      name = $data_system.elements[ft.data_id]
      suffix = ((2..10).to_a + [35, 36]).include?(ft.data_id) ? "属性" : "特攻"
      "#{name}#{suffix}"
    end

    #--------------------------------------------------------------------------
    # ● 攻撃時ステート名の取得
    #--------------------------------------------------------------------------
    def atk_state_name(ft)
      name = $data_states[ft.data_id].name
      "#{name}付与"
    end

    #--------------------------------------------------------------------------
    # ● 攻撃速度補正名の取得
    #--------------------------------------------------------------------------
    def atk_speed_name(ft)
      "攻撃速度補正"
    end

    #--------------------------------------------------------------------------
    # ● 攻撃追加回数名の取得
    #--------------------------------------------------------------------------
    def atk_times_name(ft)
      "#{ft.value.to_i + 1}回攻撃"
    end

    #--------------------------------------------------------------------------
    # ● スキルタイプ追加名の取得
    #--------------------------------------------------------------------------
    def stype_add_name(ft)
      name = $data_system.skill_types[ft.data_id]
      "#{name}使用可能"
    end

    #--------------------------------------------------------------------------
    # ● スキルタイプ封印名の取得
    #--------------------------------------------------------------------------
    def stype_seal_name(ft)
      name = $data_system.skill_types[ft.data_id]
      "#{name}使用不可"
    end

    #--------------------------------------------------------------------------
    # ● 武器装備可能名の取得
    #--------------------------------------------------------------------------
    def equip_wtype_name(ft)
      name = $data_system.weapon_types[ft.data_id]
      "#{name}装備可能"
    end

    #--------------------------------------------------------------------------
    # ● 防具装備可能名の取得
    #--------------------------------------------------------------------------
    def equip_atype_name(ft)
      name = $data_system.armor_types[ft.data_id]
      "#{name}装備可能"
    end

    #--------------------------------------------------------------------------
    # ● 装備固定名の取得
    #--------------------------------------------------------------------------
    def equip_fix_name(ft)
      name = Vocab.etype(ft.data_id)
      "#{name}装備固定"
    end

    #--------------------------------------------------------------------------
    # ● 装備封印名の取得
    #--------------------------------------------------------------------------
    def equip_seal_name(ft)
      name = Vocab.etype(ft.data_id)
      "#{name}装備不可"
    end

    #--------------------------------------------------------------------------
    # ● スロットタイプ名の取得
    #--------------------------------------------------------------------------
    def slot_type_name(ft)
      case ft.data_id
      when 1
        "二刀流"
      when 2
        "両手盾"
      when 3
        "三刀流"
      else
        "空項目"
      end
    end

    #--------------------------------------------------------------------------
    # ● 行動回数追加名の取得
    #--------------------------------------------------------------------------
    def action_plus_name(ft)
      "#{ft.value.floor + 1}回行動"
    end

    #--------------------------------------------------------------------------
    # ● 特殊フラグ名の取得
    #--------------------------------------------------------------------------
    def special_flag_name(ft)
      flag_name_table = {
        AUTO_BATTLE => "暴走",
        GUARD => "ダメージ軽減",
        SUBSTITUTE => "身代わり",
        PRESERVE_TP => "SP持ち越し"
      }
      flag_name_table[ft.data_id]
    end

    #--------------------------------------------------------------------------
    # ● 消滅エフェクト名の取得
    #--------------------------------------------------------------------------
    def collaplse_type_name(ft)
      type_name = "不滅"
      type_name = "ボス" if ft.data_id == 1
      type_name = "瞬間" if ft.data_id == 2
      "消滅エフェクト：#{type_name}"
    end

    #--------------------------------------------------------------------------
    # ● パーティアビリティ名の取得
    #--------------------------------------------------------------------------
    def party_ability_name(ft)
      ability_name_table = {
        ENCOUNTER_HALF => "エンカウント半減",
        ENCOUNTER_NONE => "エンカウント無効",
        CANCEL_SURPRISE => "不意打ち無効",
        RAISE_PREEMPTIVE => "先制攻撃率アップ",
        GOLD_DOUBLE => "獲得金額アップ",
        DROP_ITEM_DOUBLE => "ドロップ率アップ"
      }
      ability_name_table[ft.data_id]
    end

    #--------------------------------------------------------------------------
    # ● 拡張追加能力補正名の取得
    #--------------------------------------------------------------------------
    def xparam_ex_name(ft)
      xparam_name_table = [
        "命中率",
        "回避率",
        "会心率",
        "会心回避率",
        "魔法回避率",
        "魔法反射率",
        "カウンター",
        "ターンHP回復",
        "ターンMP回復",
        "ターンSP回復"
      ]
      name = xparam_name_table[ft.data_id]
      rate = (ft.value * 100.0).to_i
      case ft.data_id
      when 0
        "#{name}#{rate}%"
      else
        "#{name}アップ#{rate}%"
      end
    end

    #--------------------------------------------------------------------------
    # ● 拡張パーティアビリティ名の取得
    #--------------------------------------------------------------------------
    def party_ex_ability_name(ft)
      method_table = {
        GET_GOLD_RATE => :get_gold_rate_name,
        GET_ITEM_RATE => :get_item_rate_name,
        ENCOUNTER_RATE => :encounter_rate_name,
        COLLECT_RATE => :collect_rate_name,
        SLOT_CHANCE => :slot_chance_name,
        UNLOCK_LEVEL => :unlock_level_name
      }
      method_name = method_table[ft.data_id]
      method_name ? send(method_name, ft) : "UNKNOWN:PartyExAbility"
    end

    #--------------------------------------------------------------------------
    # ● 獲得金額倍率名の取得
    #--------------------------------------------------------------------------
    def get_gold_rate_name(ft)
      rate = (ft.value * 100.0).to_i - 100
      "獲得ゴールド#{0 < rate ? 'アップ' : 'ダウン'}"
    end

    #--------------------------------------------------------------------------
    # ● 獲得アイテム倍率名の取得
    #--------------------------------------------------------------------------
    def get_item_rate_name(ft)
      rate = (ft.value * 100.0).to_i - 100
      "ドロップ率#{0 < rate ? 'アップ' : 'ダウン'}"
    end

    #--------------------------------------------------------------------------
    # ● エンカウント倍率名の取得
    #--------------------------------------------------------------------------
    def encounter_rate_name(ft)
      rate = (ft.value * 100.0).to_i - 100
      return "エンカウントなし" if ft.value == 0.0

      "エンカウント率#{0 < rate ? 'アップ' : 'ダウン'}"
    end

    #--------------------------------------------------------------------------
    # ● 仲間加入倍率名の取得
    #--------------------------------------------------------------------------
    def collect_rate_name(ft)
      rate = (ft.value * 100.0).to_i - 100
      "仲間になり#{0 < rate ? 'やすい' : 'にくい'}"
    end

    #--------------------------------------------------------------------------
    # ● スロットチャンス名の取得
    #--------------------------------------------------------------------------
    def slot_chance_name(ft)
      "スロット運上昇"
    end

    #--------------------------------------------------------------------------
    # ● 解錠レベル名の取得
    #--------------------------------------------------------------------------
    def unlock_level_name(ft)
      "解錠レベル#{ft.value}"
    end

    #--------------------------------------------------------------------------
    # ● バトラーアビリティ名の取得
    #--------------------------------------------------------------------------
    def battler_ability_name(ft)
      method_table = {
        STEAL_SUCCESS => :steal_success_name,
        AUTO_STAND => :auto_stand_name,
        HEEL_REVERSE => :heel_reverse_name,
        AUTO_STATE => :auto_state_names,
        TRIGGER_STATE => :trigger_state_name,
        METAL_BODY => :metal_body_name,
        DEFENSE_WALL => :defense_wall_name,
        INVALIDATE_WALL => :invalidate_wall_name,
        DAMAGE_MP_CONVERT => :damage_mp_convert_name,
        DAMAGE_GOLD_CONVERT => :damage_gold_convert_name,
        DAMAGE_MP_DRAIN => :damage_mp_drain_name,
        DAMAGE_GOLD_DRAIN => :damage_gold_drain_name,
        DEAD_SKILL => :dead_skill_name,
        BATTLE_START_SKILL => :battle_start_skill_name,
        TURN_START_SKILL => :turn_start_skill_name,
        TURN_END_SKILL => :turn_end_skill_name,
        CHANGE_ACTION => :change_action_names,
        STYPE_COST_RATE => :stype_cost_rate_name,
        SKILL_COST_RATE => :skill_cost_rate_name,
        TP_COST_RATE => :tp_cost_rate_name,
        HP_COST_RATE => :hp_cost_rate_name,
        GOLD_COST_RATE => :gold_cost_rate_name,
        INCREASE_TP => :increase_tp_name,
        START_TP_RATE => :start_tp_rate_name,
        BATTLE_END_HEEL_HP => :battle_end_heel_hp_name,
        BATTLE_END_HEEL_MP => :battle_end_heel_mp_name,
        Battler::NORMAL_ATTACK => :normal_attack_name,
        FINAL_INVOKE => :final_invoke_names,
        CERTAIN_COUNTER => :certain_counter_name,
        MAGICAL_COUNTER => :magical_counter_name,
        PHYSICAL_COUNTER_EX => :physical_counter_ex_name,
        MAGICAL_COUNTER_EX => :magical_counter_ex_name,
        CERTAIN_COUNTER_EX => :certain_counter_ex_name,
        CONSIDERATE => :considerate_name,
        GET_EXP_RATE => :get_exp_rate_name,
        GET_CLASSEXP_RATE => :get_classexp_rate_name,
        INVOKE_REPEATS_TYPE => :invoke_repeats_type_names,
        INVOKE_REPEATS_SKILL => :invoke_repeats_skill_names,
        OWN_CRUSH_RESIST => :own_crush_resist_name,
        IGNORE_OVER_DRIVE => :ignore_over_drive_name,
        INSTANT_DEAD_REVERSE => :instant_dead_reverse_name,
        CHANGE_SKILL => :change_skill_name,
        PHYSICAL_REFLECTION => :physical_reclection_name,
        SLOT_CANNOT_DUAL_WIELD => :slot_cannot_dual_wield_name
      }
      method_name = method_table[ft.data_id]
      method_name ? send(method_name, ft) : nil
      # return method_name ? send(method_name, ft) : "UNKNOWN:BattlerAbility #{ft.data_id}"★
    end

    #--------------------------------------------------------------------------
    # ● 盗み成功率名の取得
    #--------------------------------------------------------------------------
    def steal_success_name(ft)
      rate = (ft.value * 100.0).to_i - 100
      "盗み成功率#{rate}%#{0 < rate ? 'アップ' : 'ダウン'}"
    end

    #--------------------------------------------------------------------------
    # ● 踏みとどまり名の取得
    #--------------------------------------------------------------------------
    def auto_stand_name(ft)
      "食いしばり"
    end

    #--------------------------------------------------------------------------
    # ● 回復反転名の取得
    #--------------------------------------------------------------------------
    def heel_reverse_name(ft)
      "回復反転"
    end

    #--------------------------------------------------------------------------
    # ● オートステート名配列の取得
    #--------------------------------------------------------------------------
    def auto_state_names(ft)
      names = ft.value.collect { |state_id| $data_states[state_id].name }
      names.collect { |name| "戦闘開始時#{name}付与" }
    end

    #--------------------------------------------------------------------------
    # ● トリガーステート名の取得
    #--------------------------------------------------------------------------
    def trigger_state_name(ft)
      name = $data_states[ft.value[:state_id]].name
      return nil if (ft.value[:trigger] / 2) > 0

      "ピンチ時#{name}発動"
    end

    #--------------------------------------------------------------------------
    # ● メタルボディ名の取得
    #--------------------------------------------------------------------------
    def metal_body_name(ft)
      "メタルボディ"
    end

    #--------------------------------------------------------------------------
    # ● 防御壁展開名の取得
    #--------------------------------------------------------------------------
    def defense_wall_name(ft)
      "防御壁"
    end

    #--------------------------------------------------------------------------
    # ● 無効化障壁名の取得
    #--------------------------------------------------------------------------
    def invalidate_wall_name(ft)
      "無効化障壁"
    end

    #--------------------------------------------------------------------------
    # ● ダメージMP変換名の取得
    #--------------------------------------------------------------------------
    def damage_mp_convert_name(ft)
      "身代わりMP消費"
    end

    #--------------------------------------------------------------------------
    # ● ダメージゴールド変換名の取得
    #--------------------------------------------------------------------------
    def damage_gold_convert_name(ft)
      "身代わりお金消費"
    end

    #--------------------------------------------------------------------------
    # ● ダメージMP吸収名の取得
    #--------------------------------------------------------------------------
    def damage_mp_drain_name(ft)
      "被ダメージ時MP吸収"
    end

    #--------------------------------------------------------------------------
    # ● ダメージゴールド回収名の取得
    #--------------------------------------------------------------------------
    def damage_gold_drain_name(ft)
      "被ダメージ時お金回収"
    end

    #--------------------------------------------------------------------------
    # ● 死亡時スキル名の取得
    #--------------------------------------------------------------------------
    def dead_skill_name(ft)
      name = $data_skills[ft.value].name
      "戦闘不能時#{name}発動"
    end

    #--------------------------------------------------------------------------
    # ● 戦闘開始時スキル名の取得
    #--------------------------------------------------------------------------
    def battle_start_skill_name(ft)
      name   = $data_skills[ft.value[:id]].name
      prefix = ft.value[:per] == 1.0 ? "" : "時々"
      "戦闘開始時#{prefix}#{name}発動"
    end

    #--------------------------------------------------------------------------
    # ● ターン開始時スキル名の取得
    #--------------------------------------------------------------------------
    def turn_start_skill_name(ft)
      name = $data_skills[ft.value[:id]].name
      prefix = ft.value[:per] == 1.0 ? "" : "時々"
      "ターン開始時#{prefix}#{name}発動"
    end

    #--------------------------------------------------------------------------
    # ● ターン終了時スキル名の取得
    #--------------------------------------------------------------------------
    def turn_end_skill_name(ft)
      name = $data_skills[ft.value[:id]].name
      prefix = ft.value[:per] == 1.0 ? "" : "時々"
      "ターン終了時#{prefix}#{name}発動"
    end

    #--------------------------------------------------------------------------
    # ● 行動変化名配列の取得
    #--------------------------------------------------------------------------
    def change_action_names(ft)
      nil
    end

    #--------------------------------------------------------------------------
    # ● スキルタイプ消費率名を取得
    #--------------------------------------------------------------------------
    def stype_cost_rate_name(ft)
      name = $data_system.skill_types[ft.value[:id]]
      type = ft.value[:type].to_s
      type = "SP" if type == "TP"
      rate = (ft.value[:rate] * 100.0).to_i - 100
      "#{name}消費#{type}#{0 < rate ? 'アップ' : 'ダウン'}"
    end

    #--------------------------------------------------------------------------
    # ● スキル消費率名を取得
    #--------------------------------------------------------------------------
    def skill_cost_rate_name(ft)
      name = $data_skills[ft.value[:id]].name
      type = ft.value[:type].to_s
      type = "SP" if type == "TP"
      rate = (ft.value[:rate] * 100.0).to_i - 100
      "#{name}消費#{type}#{0 < rate ? 'アップ' : 'ダウン'}"
    end

    #--------------------------------------------------------------------------
    # ● TP消費率名を取得
    #--------------------------------------------------------------------------
    def tp_cost_rate_name(ft)
      rate = (ft.value * 100.0).to_i - 100
      "SP消費#{0 < rate ? 'アップ' : 'ダウン'}"
    end

    #--------------------------------------------------------------------------
    # ● HP消費率名を取得
    #--------------------------------------------------------------------------
    def hp_cost_rate_name(ft)
      rate = (ft.value * 100.0).to_i - 100
      "HP消費#{0 < rate ? 'アップ' : 'ダウン'}"
    end

    #--------------------------------------------------------------------------
    # ● ゴールド消費率名を取得
    #--------------------------------------------------------------------------
    def gold_cost_rate_name(ft)
      rate = (ft.value * 100.0).to_i - 100
      "ゴールド消費#{0 < rate ? 'アップ' : 'ダウン'}"
    end

    #--------------------------------------------------------------------------
    # ● 最大TP増減名を取得
    #--------------------------------------------------------------------------
    def increase_tp_name(ft)
      "最大SP#{ft.value[:plus] ? 'アップ' : 'ダウン'}"
    end

    #--------------------------------------------------------------------------
    # ● 開始時TP名を取得
    #--------------------------------------------------------------------------
    def start_tp_rate_name(ft)
      rate = (ft.value * 100.0).to_i
      "開始時SP#{rate}%"
    end

    #--------------------------------------------------------------------------
    # ● 戦闘後HP回復名を取得
    #--------------------------------------------------------------------------
    def battle_end_heel_hp_name(ft)
      "戦闘後HP回復"
    end

    #--------------------------------------------------------------------------
    # ● 戦闘後MP回復名を取得
    #--------------------------------------------------------------------------
    def battle_end_heel_mp_name(ft)
      "戦闘後MP回復"
    end

    #--------------------------------------------------------------------------
    # ● 通常攻撃名を取得
    #--------------------------------------------------------------------------
    def normal_attack_name(ft)
      $data_skills[ft.value].name
    end

    #--------------------------------------------------------------------------
    # ● 反撃スキル名配列を取得
    #--------------------------------------------------------------------------
    def counter_skill_names(ft)
      ft.value.collect { |skill_id| $data_skills[skill_id].name }
    end

    #--------------------------------------------------------------------------
    # ● 最終反撃名配列を取得
    #--------------------------------------------------------------------------
    def final_invoke_names(ft)
      names = ft.value.collect { |skill_id| $data_skills[skill_id].name }
      names.collect { |name| "戦闘不能時「#{name}」" }
    end

    #--------------------------------------------------------------------------
    # ● 必中反撃名を取得
    #--------------------------------------------------------------------------
    def certain_counter_name(ft)
      "万能カウンター"
    end

    #--------------------------------------------------------------------------
    # ● 魔法反撃名を取得
    #--------------------------------------------------------------------------
    def magical_counter_name(ft)
      "魔法カウンター"
    end

    #--------------------------------------------------------------------------
    # ● 拡張物理反撃名を取得
    #--------------------------------------------------------------------------
    def physical_counter_ex_name(ft)
      nil
    end

    #--------------------------------------------------------------------------
    # ● 拡張魔法反撃名を取得
    #--------------------------------------------------------------------------
    def magical_counter_ex_name(ft)
      nil
    end

    #--------------------------------------------------------------------------
    # ● 拡張必中反撃名を取得
    #--------------------------------------------------------------------------
    def certain_counter_ex_name(ft)
      nil
    end

    #--------------------------------------------------------------------------
    # ● 仲間想い名を取得
    #--------------------------------------------------------------------------
    def considerate_name(ft)
      "仲間戦闘不能時攻撃強化"
    end

    #--------------------------------------------------------------------------
    # ● 獲得経験値倍率名を取得
    #--------------------------------------------------------------------------
    def get_exp_rate_name(ft)
      rate = (ft.value * 100.0).to_i - 100
      "経験値#{0 < rate ? 'アップ' : 'ダウン'}"
    end

    #--------------------------------------------------------------------------
    # ● 獲得職業経験値倍率名を取得
    #--------------------------------------------------------------------------
    def get_classexp_rate_name(ft)
      rate = (ft.value * 100.0).to_i - 100
      "職業経験値#{0 < rate ? 'アップ' : 'ダウン'}"
    end

    #--------------------------------------------------------------------------
    # ● 連続発動タイプ名配列を取得
    #--------------------------------------------------------------------------
    def invoke_repeats_type_names(ft)
      names = []
      ft.value.each do |key, _val|
        names.push("#{$data_system.skill_types[key]}連続発動")
      end
      names
    end

    #--------------------------------------------------------------------------
    # ● 連続発動スキル名配列を取得
    #--------------------------------------------------------------------------
    def invoke_repeats_skill_names(ft)
      names = []
      ft.value.each do |key, _val|
        names.push("#{$data_skills[key].name}連続発動")
      end
      names
    end

    #--------------------------------------------------------------------------
    # ● 自爆耐性名を取得
    #--------------------------------------------------------------------------
    def own_crush_resist_name(ft)
      "自爆耐性"
    end

    #--------------------------------------------------------------------------
    # ● 属性吸収名配列を取得
    #--------------------------------------------------------------------------
    def element_drain_name(ft)
      "#{$data_system.elements[ft.data_id]}吸収"
    end

    #--------------------------------------------------------------------------
    # ● 時間停止無視を取得
    #--------------------------------------------------------------------------
    def ignore_over_drive_name(ft)
      "時間停止無視"
    end

    #--------------------------------------------------------------------------
    # ● 即死反転を取得
    #--------------------------------------------------------------------------
    def instant_dead_reverse_name(ft)
      nil
    end

    #--------------------------------------------------------------------------
    # ● スキル変化を取得
    #--------------------------------------------------------------------------
    def change_skill_name(ft)
      nil
    end

    #--------------------------------------------------------------------------
    # ● マルチブースター名の取得
    #--------------------------------------------------------------------------
    def multi_booster_name(ft)
      method_table = {
        ELEMENT => :booster_element_name,
        WEAPON_PHYSICAL => :booster_weapon_physical_name,
        WEAPON_MAGICAL => :booster_weapon_magical_name,
        WEAPON_CERTAIN => :booster_weapon_certain_name,
        Booster::NORMAL_ATTACK => :booster_normal_attack_name,
        STATE_RATIO_TYPE => :booster_state_ratio_type_name,
        STATE_FIX_TYPE => :booster_state_fix_type_name,
        SKILL_TYPE => :booster_skill_type_name,
        STATE_RATIO_SKILL => :booster_state_ratio_skill_name,
        SKILL => :booster_skill_name,
        WTYPE_SKILL => :booster_wtype_skill_name,
        COUNTER => :booster_counter_name,
        FALL_HP => :booster_fall_hp_name,
        OVER_SOUL => :over_soul_name,
        CRITICAL => :booster_critical_name
      }
      method_name = method_table[ft.data_id]
      method_name ? send(method_name, ft) : nil
      # return method_name ? send(method_name, ft) : "UNKNOWN:MultiBooster" ★
    end

    #--------------------------------------------------------------------------
    # ● 属性ブースター倍率名を取得
    #--------------------------------------------------------------------------
    def booster_element_name(ft)
      names = []
      ft.value.each do |key, _val|
        names.push("#{$data_system.elements[key]}属性強化")
      end
      names
    end

    #--------------------------------------------------------------------------
    # ● 武器強化物理倍率名を取得
    #--------------------------------------------------------------------------
    def booster_weapon_physical_name(ft)
      names = []
      ft.value.each do |key, _val|
        names.push("#{$data_system.weapon_types[key]}装備時物理強化")
      end
      names
    end

    #--------------------------------------------------------------------------
    # ● 武器強化魔法倍率名を取得
    #--------------------------------------------------------------------------
    def booster_weapon_magical_name(ft)
      names = []
      ft.value.each do |key, _val|
        names.push("#{$data_system.weapon_types[key]}装備時魔法強化")
      end
      names
    end

    #--------------------------------------------------------------------------
    # ● 武器強化必中倍率名を取得
    #--------------------------------------------------------------------------
    def booster_certain_magical_name(ft)
      names = []
      ft.value.each do |key, _val|
        names.push("#{$data_system.weapon_types[key]}装備時万能強化")
      end
      names
    end

    #--------------------------------------------------------------------------
    # ● 通常攻撃強化倍率名を取得
    #--------------------------------------------------------------------------
    def booster_normal_attack_name(ft)
      nil
    end

    #--------------------------------------------------------------------------
    # ● ステート割合強化タイプ倍率名を取得
    #--------------------------------------------------------------------------
    def booster_state_ratio_type_name(ft)
      names = []
      ft.value.each do |key, _val|
        names.push("#{$data_system.skill_types[key]}付与率アップ")
      end
      names
    end

    #--------------------------------------------------------------------------
    # ● ステート固定強化タイプ倍率名を取得
    #--------------------------------------------------------------------------
    def booster_state_fix_type_name(ft)
      names = []
      ft.value.each do |key, _val|
        names.push("#{$data_system.skill_types[key]}付与率アップ")
      end
      names
    end

    #--------------------------------------------------------------------------
    # ● スキルタイプ強化倍率名を取得
    #--------------------------------------------------------------------------
    def booster_skill_type_name(ft)
      names = []
      ft.value.each do |key, _val|
        names.push("#{$data_system.skill_types[key]}強化")
      end
      names
    end

    #--------------------------------------------------------------------------
    # ● ステート割合強化スキル倍率名を取得
    #--------------------------------------------------------------------------
    def booster_state_ratio_skill_name(ft)
      names = []
      ft.value.each do |key, _val|
        names.push("#{$data_skills[key].name}付与率アップ")
      end
      names
    end

    #--------------------------------------------------------------------------
    # ● スキル強化倍率名を取得
    #--------------------------------------------------------------------------
    def booster_skill_name(ft)
      names = []
      ft.value.each do |key, _val|
        names.push("#{$data_skills[key].name}強化")
      end
      names
    end

    #--------------------------------------------------------------------------
    # ● 武器スキル強化倍率名を取得
    #--------------------------------------------------------------------------
    def booster_wtype_skill_name(ft)
      names = []
      ft.value.each do |key, _val|
        name = key[0] == 0 ? "素手時" : "#{$data_system.weapon_types[key[0]]}装備時"
        name += "#{$data_system.skill_types[key[1]]}強化"
        names.push(name)
      end
      names
    end

    #--------------------------------------------------------------------------
    # ● カウンター強化倍率名を取得
    #--------------------------------------------------------------------------
    def booster_counter_name(ft)
      "カウンター攻撃力アップ"
    end

    #--------------------------------------------------------------------------
    # ● HP減少時強化倍率名を取得
    #--------------------------------------------------------------------------
    def booster_fall_hp_name(ft)
      "瀕死時能力アップ"
    end

    #--------------------------------------------------------------------------
    # ● オーバーソウル名を取得
    #--------------------------------------------------------------------------
    def over_soul_name(ft)
      "仲間戦闘不能時能力アップ"
    end

    #--------------------------------------------------------------------------
    # ● 解説追加名を取得
    #--------------------------------------------------------------------------
    def dummy_enchant_name(ft)
      value = ft.value
      if enchant_item?

        value = value.gsub(/\\e\[(\d+|\d+-\d+)\]/i) do
          dummy_enchant_value(ft, Regexp.last_match(1))
        end
      end
      value = value.split("\\n")
      if ft.display_color >= 0
        value.map!  do |line|
          "\\c[#{ft.display_color}]#{line}"
        end
      end
      value
    end

    def dummy_enchant_value(ft, value)
      e = Enchant_Value.new(:int, value)
      v = @enchants_variance
      if !v.key?(ft.enchant_id) || !v[ft.enchant_id].key?(e.calc_id) || !v[ft.enchant_id][e.calc_id].key?(e.variance_id)
        return -1
      end

      data = NWConst::Enchantment::FEATURE_CALCULATION[e.calc_id]
      n = e.calculation(rarity_num, @enchants_variance[ft.enchant_id][e.calc_id][e.variance_id])
      data.key?(:txt_value) ? eval(data[:txt_value]) : n
    end

    #--------------------------------------------------------------------------
    # ● 地形強化名を取得
    #--------------------------------------------------------------------------
    def terrain_booster_name(ft)
      "#{ft.data_id}#{0.2 < ft.value ? '超' : ''}強化"
    end

    #--------------------------------------------------------------------------
    # ● 物理反射率名を取得
    #--------------------------------------------------------------------------
    def physical_reclection_name(ft)
      rate = (ft.value * 100.0).to_i
      "物理反射率#{0 < rate ? 'アップ' : 'ダウン'}#{rate.abs}%"
    end

    #--------------------------------------------------------------------------
    # ● 装備マスタリー名を取得
    #--------------------------------------------------------------------------
    def equip_mastery_name(ft)
      "マスタリー"
    end

    #--------------------------------------------------------------------------
    # ● 二刀流スロット不可能名を取得
    #--------------------------------------------------------------------------
    def slot_cannot_dual_wield_name(ft)
      nil
    end

    def block_rate_name(ft)
      pre = case ft.data_id
            when HitType::CERTAIN
              "万能"
            when HitType::MAGICAL
              "魔法"
            when HitType::PHYSICAL
              "物理"
            end
      "#{pre}ブロック率#{(ft.value * 100).to_i}%"
    end

    def booster_critical_name(ft)
      "会心ダメージアップ#{(ft.value * 100).to_i}%"
    end
  end
end
