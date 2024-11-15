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
      "Количество Гнезд:#{socket_num}"
    end

    #--------------------------------------------------------------------------
    # ● 属性有効度名の取得
    #--------------------------------------------------------------------------
    def element_rate_name(ft)
      name = $data_system.elements[ft.data_id]
      rate = (ft.value * 100.0).to_i - 100
      "Сопр. к #{name} #{0 < rate ? '-' : '+'}#{rate.abs}%"
    end

    #--------------------------------------------------------------------------
    # ● 弱体有効度名の取得
    #--------------------------------------------------------------------------
    def debuff_rate_name(ft)
      name = Vocab.param(ft.data_id)
      rate = (ft.value * 100.0).to_i - 100
      "Сопр. к Снижению #{name} #{0 < rate ? '-' : '+'}"
    end

    #--------------------------------------------------------------------------
    # ● ステート有効度名の取得
    #--------------------------------------------------------------------------
    def state_rate_name(ft)
      name = $data_states[ft.data_id].name
      rate = (ft.value * 100.0).to_i - 100
      "Сопр. к #{name} #{0 < rate ? '-' : '+'}#{rate.abs}%"
    end

    #--------------------------------------------------------------------------
    # ● ステート無効化名の取得
    #--------------------------------------------------------------------------
    def state_resist_name(ft)
      name = $data_states[ft.data_id].name
      "Иммун. к #{name}"
    end

    #--------------------------------------------------------------------------
    # ● 通常能力補正名の取得
    #--------------------------------------------------------------------------
    def param_name(ft)
      name = Vocab.param(ft.data_id)
      rate = (ft.value * 100.0).to_i
      "#{name} = #{rate}%"
    end

    #--------------------------------------------------------------------------
    # ● 追加能力補正名の取得
    #--------------------------------------------------------------------------
    def xparam_name(ft)
      xparam_name_table = [
        "Точность",
        "Уворот",
        "Критический Удар",
        "Шанс Избегания Крита",
        "Магический Уворот",
        "Отражение Магии",
        "Контратака",
        "Реген. HP",
        "Реген. MP",
        "Реген. SP"
      ]
      name = xparam_name_table[ft.data_id]
      rate = (ft.value * 100.0).to_i
      case ft.data_id
      when 0
        "#{name} +#{rate}%"
      else
        "#{name} #{rate}%"
      end
    end

    #--------------------------------------------------------------------------
    # ● 特殊能力補正名の取得
    #--------------------------------------------------------------------------
    def sparam_name(ft)
      sparam_name_table = [
        "Шанс Стать Целью",
        "Эффективность Защиты",
        "Метаболизм",
        "Исцеление Предметами",
        "Затраты MP",
        "Зарядка SP",
        "Физический Урон",
        "Магический Урон",
        "Урон Окружения",
        "Набор Опыта"
      ]
      name = sparam_name_table[ft.data_id]
      rate = (ft.value * 100.0).to_i - 100
      "#{name} #{0 < rate ? '+' : ''}#{rate}%"
    end

    #--------------------------------------------------------------------------
    # ● 攻撃時属性名の取得
    #--------------------------------------------------------------------------
    def atk_element_name(ft)
      return nil unless (2..37).include?(ft.data_id)

      name = $data_system.elements[ft.data_id]
      suffix = ((2..10).to_a + [35, 36]).include?(ft.data_id) ? "Атрибут" : "Истребление"
      "#{suffix}:#{name}"
    end

    #--------------------------------------------------------------------------
    # ● 攻撃時ステート名の取得
    #--------------------------------------------------------------------------
    def atk_state_name(ft)
      name = $data_states[ft.data_id].name
      rate = (ft.value * 100.0).to_i
      return "#{name} при Атаке +#{rate}%"
    end

    #--------------------------------------------------------------------------
    # ● 攻撃速度補正名の取得
    #--------------------------------------------------------------------------
    def atk_speed_name(ft)
      "Приоритет Атаки"
    end

    #--------------------------------------------------------------------------
    # ● 攻撃追加回数名の取得
    #--------------------------------------------------------------------------
    def atk_times_name(ft)
      "#{ft.value.to_i + 1} Атак"
    end

    #--------------------------------------------------------------------------
    # ● スキルタイプ追加名の取得
    #--------------------------------------------------------------------------
    def stype_add_name(ft)
      name = $data_system.skill_types[ft.data_id]
      "Доступ:#{name}"
    end

    #--------------------------------------------------------------------------
    # ● スキルタイプ封印名の取得
    #--------------------------------------------------------------------------
    def stype_seal_name(ft)
      name = $data_system.skill_types[ft.data_id]
      "Запрет:#{name}"
    end

    #--------------------------------------------------------------------------
    # ● 武器装備可能名の取得
    #--------------------------------------------------------------------------
    def equip_wtype_name(ft)
      name = $data_system.weapon_types[ft.data_id]
      "Экипировать:#{name}"
    end

    #--------------------------------------------------------------------------
    # ● 防具装備可能名の取得
    #--------------------------------------------------------------------------
    def equip_atype_name(ft)
      name = $data_system.armor_types[ft.data_id]
      "Экипировать:#{name}"
    end

    #--------------------------------------------------------------------------
    # ● 装備固定名の取得
    #--------------------------------------------------------------------------
    def equip_fix_name(ft)
      name = Vocab.etype(ft.data_id)
      "Экипировать Только:#{name}"
    end

    #--------------------------------------------------------------------------
    # ● 装備封印名の取得
    #--------------------------------------------------------------------------
    def equip_seal_name(ft)
      name = Vocab.etype(ft.data_id)
      "Запрет Экип.:#{name}"
    end

    #--------------------------------------------------------------------------
    # ● スロットタイプ名の取得
    #--------------------------------------------------------------------------
    def slot_type_name(ft)
      case ft.data_id
      when 1
        "Парное Оружие"
      when 2
        "Два Щита"
      when 3
        "Стиль Трех Мечей"
      else
        "Пустой Слот"
      end
    end

    #--------------------------------------------------------------------------
    # ● 行動回数追加名の取得
    #--------------------------------------------------------------------------
    def action_plus_name(ft)
      "#{ft.value.floor + 1} Действия"
    end

    #--------------------------------------------------------------------------
    # ● 特殊フラグ名の取得
    #--------------------------------------------------------------------------
    def special_flag_name(ft)
      flag_name_table = {
        AUTO_BATTLE => "Авто-Бой",
        GUARD => "Блок",
        SUBSTITUTE => "Прикрытие",
        PRESERVE_TP => "Сохранение SP"
      }
      flag_name_table[ft.data_id]
    end

    #--------------------------------------------------------------------------
    # ● 消滅エフェクト名の取得
    #--------------------------------------------------------------------------
    def collaplse_type_name(ft)
      type_name = "Бессмертный"
      type_name = "Босс" if ft.data_id == 1
      type_name = "Мгновенно" if ft.data_id == 2
      "Эффект Смерти：#{type_name}"
    end

    #--------------------------------------------------------------------------
    # ● パーティアビリティ名の取得
    #--------------------------------------------------------------------------
    def party_ability_name(ft)
      ability_name_table = {
        ENCOUNTER_HALF => "Стычки Ополовинены",
        ENCOUNTER_NONE => "Нет Стычек",
        CANCEL_SURPRISE => "Нет Засад",
        RAISE_PREEMPTIVE => "Чаще Шанс Первого Удара",
        GOLD_DOUBLE => "Удвоение Выпадения Золота",
        DROP_ITEM_DOUBLE => "Удвоение Выпадения Вещей"
      }
      ability_name_table[ft.data_id]
    end

    #--------------------------------------------------------------------------
    # ● 拡張追加能力補正名の取得
    #--------------------------------------------------------------------------
    def xparam_ex_name(ft)
      xparam_name_table = [
        "Точность",
        "Уворот",
        "Критический Удар",
        "Шанс Избегания Крита",
        "Магический Уворот",
        "Отражение Магии",
        "Контратака",
        "Реген. HP",
        "Реген. MP",
        "Реген. SP"
      ]
      name = xparam_name_table[ft.data_id]
      rate = (ft.value * 100.0).to_i
      case ft.data_id
      when 0
        "#{name} #{rate}%"
      else
        "#{name} +#{rate}%"
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
      "Получаемое Золото #{0 < rate ? '+' : ''}#{rate}%"
    end

    #--------------------------------------------------------------------------
    # ● 獲得アイテム倍率名の取得
    #--------------------------------------------------------------------------
    def get_item_rate_name(ft)
      rate = (ft.value * 100.0).to_i - 100
      "Выпадение Предметов #{0 < rate ? '+' : ''}#{rate}%"
    end

    #--------------------------------------------------------------------------
    # ● エンカウント倍率名の取得
    #--------------------------------------------------------------------------
    def encounter_rate_name(ft)
      rate = (ft.value * 100.0).to_i - 100
      return "Нет Стычек" if ft.value == 0.0

      "Шанс Стычек #{0 < rate ? '+' : ''}#{rate}%"
    end

    #--------------------------------------------------------------------------
    # ● 仲間加入倍率名の取得
    #--------------------------------------------------------------------------
    def collect_rate_name(ft)
      rate = (ft.value * 100.0).to_i - 100
      "Шанс Присоединения #{0 < rate ? '+' : ''}#{rate}%"
    end

    #--------------------------------------------------------------------------
    # ● スロットチャンス名の取得
    #--------------------------------------------------------------------------
    def slot_chance_name(ft)
      "Удача в Слот-Машине"
    end

    #--------------------------------------------------------------------------
    # ● 解錠レベル名の取得
    #--------------------------------------------------------------------------
    def unlock_level_name(ft)
      "Отмычка #{ft.value}"
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
      "Шанс Кражи #{0 < rate ? '+' : ''}#{rate}%"
    end

    #--------------------------------------------------------------------------
    # ● 踏みとどまり名の取得
    #--------------------------------------------------------------------------
    def auto_stand_name(ft)
      "Стойкость"
    end

    #--------------------------------------------------------------------------
    # ● 回復反転名の取得
    #--------------------------------------------------------------------------
    def heel_reverse_name(ft)
      "Урон от Исцеления"
    end

    #--------------------------------------------------------------------------
    # ● オートステート名配列の取得
    #--------------------------------------------------------------------------
    def auto_state_names(ft)
      names = ft.value.collect { |state_id| $data_states[state_id].name }
      names.collect { |name| "В Начале Боя:#{name}" }
    end

    #--------------------------------------------------------------------------
    # ● トリガーステート名の取得
    #--------------------------------------------------------------------------
    def trigger_state_name(ft)
      name = $data_states[ft.value[:state_id]].name
      return nil if (ft.value[:trigger] / 2) > 0

      "Мало HP:#{name}"
    end

    #--------------------------------------------------------------------------
    # ● メタルボディ名の取得
    #--------------------------------------------------------------------------
    def metal_body_name(ft)
      "Металлическое Тело"
    end

    #--------------------------------------------------------------------------
    # ● 防御壁展開名の取得
    #--------------------------------------------------------------------------
    def defense_wall_name(ft)
      "Защитный Барьер"
    end

    #--------------------------------------------------------------------------
    # ● 無効化障壁名の取得
    #--------------------------------------------------------------------------
    def invalidate_wall_name(ft)
      "Обнуляющий Барьер <= #{ft.value}"
    end

    #--------------------------------------------------------------------------
    # ● ダメージMP変換名の取得
    #--------------------------------------------------------------------------
    def damage_mp_convert_name(ft)
      "Барьер Маны"
    end

    #--------------------------------------------------------------------------
    # ● ダメージゴールド変換名の取得
    #--------------------------------------------------------------------------
    def damage_gold_convert_name(ft)
      "Барьер Золота"
    end

    #--------------------------------------------------------------------------
    # ● ダメージMP吸収名の取得
    #--------------------------------------------------------------------------
    def damage_mp_drain_name(ft)
      "Урон Дает MP"
    end

    #--------------------------------------------------------------------------
    # ● ダメージゴールド回収名の取得
    #--------------------------------------------------------------------------
    def damage_gold_drain_name(ft)
      "Урон Дает Золото"
    end

    #--------------------------------------------------------------------------
    # ● 死亡時スキル名の取得
    #--------------------------------------------------------------------------
    def dead_skill_name(ft)
      name = $data_skills[ft.value].name
      "Смерть:#{name}"
    end

    #--------------------------------------------------------------------------
    # ● 戦闘開始時スキル名の取得
    #--------------------------------------------------------------------------
    def battle_start_skill_name(ft)
      name   = $data_skills[ft.value[:id]].name
      prefix = ft.value[:per] == 1.0 ? "" : "%"
      "В Начале Боя:#{prefix}#{name}"
    end

    #--------------------------------------------------------------------------
    # ● ターン開始時スキル名の取得
    #--------------------------------------------------------------------------
    def turn_start_skill_name(ft)
      name = $data_skills[ft.value[:id]].name
      prefix = ft.value[:per] == 1.0 ? "" : "%"
      "В Начале Хода:#{prefix}#{name}"
    end

    #--------------------------------------------------------------------------
    # ● ターン終了時スキル名の取得
    #--------------------------------------------------------------------------
    def turn_end_skill_name(ft)
      name = $data_skills[ft.value[:id]].name
      prefix = ft.value[:per] == 1.0 ? "" : "%"
      "В Конце Хода:#{prefix}#{name}"
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
      "#{name}: Затраты #{type}#{0 < rate ? '+' : ''}#{rate.abs}%"
    end

    #--------------------------------------------------------------------------
    # ● スキル消費率名を取得
    #--------------------------------------------------------------------------
    def skill_cost_rate_name(ft)
      name = $data_skills[ft.value[:id]].name
      type = ft.value[:type].to_s
      type = "SP" if type == "TP"
      rate = (ft.value[:rate] * 100.0).to_i - 100
      "#{name}: Затраты #{type}#{0 < rate ? '+' : ''}#{rate.abs}%"
    end

    #--------------------------------------------------------------------------
    # ● TP消費率名を取得
    #--------------------------------------------------------------------------
    def tp_cost_rate_name(ft)
      rate = (ft.value * 100.0).to_i - 100
      "Затраты SP #{0 < rate ? '+' : ''}#{rate.abs}%"
    end

    #--------------------------------------------------------------------------
    # ● HP消費率名を取得
    #--------------------------------------------------------------------------
    def hp_cost_rate_name(ft)
      rate = (ft.value * 100.0).to_i - 100
      "Затраты HP #{0 < rate ? '+' : ''}#{rate.abs}%"
    end

    #--------------------------------------------------------------------------
    # ● ゴールド消費率名を取得
    #--------------------------------------------------------------------------
    def gold_cost_rate_name(ft)
      rate = (ft.value * 100.0).to_i - 100
      "Затраты Золота #{0 < rate ? '+' : ''}#{rate.abs}%"
    end

    #--------------------------------------------------------------------------
    # ● 最大TP増減名を取得
    #--------------------------------------------------------------------------
    def increase_tp_name(ft)
      "MaxSP #{ft.value[:plus] ? '+' : '-'}#{ft.value[:num]}%"
    end

    #--------------------------------------------------------------------------
    # ● 開始時TP名を取得
    #--------------------------------------------------------------------------
    def start_tp_rate_name(ft)
      rate = (ft.value * 100.0).to_i
      "В Начале Боя:#{rate}% SP"
    end

    #--------------------------------------------------------------------------
    # ● 戦闘後HP回復名を取得
    #--------------------------------------------------------------------------
    def battle_end_heel_hp_name(ft)
      "После Боя:Реген. HP"
    end

    #--------------------------------------------------------------------------
    # ● 戦闘後MP回復名を取得
    #--------------------------------------------------------------------------
    def battle_end_heel_mp_name(ft)
      "После Боя:Реген. MP"
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
      names.collect { |name| "Смерть: #{name}" }
    end

    #--------------------------------------------------------------------------
    # ● 必中反撃名を取得
    #--------------------------------------------------------------------------
    def certain_counter_name(ft)
      "Контратака #{(ft.value * 100).to_i}%"
    end

    #--------------------------------------------------------------------------
    # ● 魔法反撃名を取得
    #--------------------------------------------------------------------------
    def magical_counter_name(ft)
      "Контрмагия #{(ft.value * 100).to_i}%"
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
      "Усиление Мстительных Атак"
    end

    #--------------------------------------------------------------------------
    # ● 獲得経験値倍率名を取得
    #--------------------------------------------------------------------------
    def get_exp_rate_name(ft)
      rate = (ft.value * 100.0).to_i - 100
      "XP #{0 < rate ? '+' : ''}#{rate}%"
    end

    #--------------------------------------------------------------------------
    # ● 獲得職業経験値倍率名を取得
    #--------------------------------------------------------------------------
    def get_classexp_rate_name(ft)
      rate = (ft.value * 100.0).to_i - 100
      "Проф. XP #{0 < rate ? '+' : ''}#{rate}%"
    end

    #--------------------------------------------------------------------------
    # ● 連続発動タイプ名配列を取得
    #--------------------------------------------------------------------------
    def invoke_repeats_type_names(ft)
      names = []
      ft.value.each do |key, _val|
        names.push("#{$data_system.skill_types[key]} Мульти-Удар")
      end
      names
    end

    #--------------------------------------------------------------------------
    # ● 連続発動スキル名配列を取得
    #--------------------------------------------------------------------------
    def invoke_repeats_skill_names(ft)
      names = []
      ft.value.each do |key, _val|
        names.push("#{$data_skills[key].name} Мульти-Удар")
      end
      names
    end

    #--------------------------------------------------------------------------
    # ● 自爆耐性名を取得
    #--------------------------------------------------------------------------
    def own_crush_resist_name(ft)
      "Иммунитет к Самоуничтожению"
    end

    #--------------------------------------------------------------------------
    # ● 属性吸収名配列を取得
    #--------------------------------------------------------------------------
    def element_drain_name(ft)
      "Поглощение #{$data_system.elements[ft.data_id]}"
    end

    #--------------------------------------------------------------------------
    # ● 時間停止無視を取得
    #--------------------------------------------------------------------------
    def ignore_over_drive_name(ft)
      "Игнорирование Остановки Времени"
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
        names.push("#{$data_system.elements[key]} Усиление")
      end
      names
    end

    #--------------------------------------------------------------------------
    # ● 武器強化物理倍率名を取得
    #--------------------------------------------------------------------------
    def booster_weapon_physical_name(ft)
      names = []
      ft.value.each do |key, _val|
        names.push("#{$data_system.weapon_types[key]} Усиление Физ. Атак")
      end
      names
    end

    #--------------------------------------------------------------------------
    # ● 武器強化魔法倍率名を取得
    #--------------------------------------------------------------------------
    def booster_weapon_magical_name(ft)
      names = []
      ft.value.each do |key, _val|
        names.push("#{$data_system.weapon_types[key]} Усиление Магии")
      end
      names
    end

    #--------------------------------------------------------------------------
    # ● 武器強化必中倍率名を取得
    #--------------------------------------------------------------------------
    def booster_certain_magical_name(ft)
      names = []
      ft.value.each do |key, _val|
        names.push("#{$data_system.weapon_types[key]} Усиление Неизб. Атак")
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
        names.push("#{$data_system.skill_types[key]} Учащение Состояний")
      end
      names
    end

    #--------------------------------------------------------------------------
    # ● ステート固定強化タイプ倍率名を取得
    #--------------------------------------------------------------------------
    def booster_state_fix_type_name(ft)
      names = []
      ft.value.each do |key, _val|
        names.push("#{$data_system.skill_types[key]} Учащение Состояний")
      end
      names
    end

    #--------------------------------------------------------------------------
    # ● スキルタイプ強化倍率名を取得
    #--------------------------------------------------------------------------
    def booster_skill_type_name(ft)
      names = []
      ft.value.each do |key, _val|
        names.push("#{$data_system.skill_types[key]} Усиление")
      end
      names
    end

    #--------------------------------------------------------------------------
    # ● ステート割合強化スキル倍率名を取得
    #--------------------------------------------------------------------------
    def booster_state_ratio_skill_name(ft)
      names = []
      ft.value.each do |key, _val|
        names.push("#{$data_skills[key].name} Учащение Состояний")
      end
      names
    end

    #--------------------------------------------------------------------------
    # ● スキル強化倍率名を取得
    #--------------------------------------------------------------------------
    def booster_skill_name(ft)
      names = []
      ft.value.each do |key, _val|
        names.push("#{$data_skills[key].name} Усиление")
      end
      names
    end

    #--------------------------------------------------------------------------
    # ● 武器スキル強化倍率名を取得
    #--------------------------------------------------------------------------
    def booster_wtype_skill_name(ft)
      names = []
      ft.value.each do |key, _val|
        name = key[0] == 0 ? "Без Оружия" : "Экип. #{$data_system.weapon_types[key[0]]}:"
        name += "#{$data_system.skill_types[key[1]]} Усиление"
        names.push(name)
      end
      names
    end

    #--------------------------------------------------------------------------
    # ● カウンター強化倍率名を取得
    #--------------------------------------------------------------------------
    def booster_counter_name(ft)
      "Урон Контратаки+"
    end

    #--------------------------------------------------------------------------
    # ● HP減少時強化倍率名を取得
    #--------------------------------------------------------------------------
    def booster_fall_hp_name(ft)
      "Параметры при Низком HP+"
    end

    #--------------------------------------------------------------------------
    # ● オーバーソウル名を取得
    #--------------------------------------------------------------------------
    def over_soul_name(ft)
      "Параметры Мести+"
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
      oldname = ft.data_id.to_s
      case oldname
      when "森"
        name = "Лесная"
      when "砂漠"
        name = "Пустынная"
      when "海"
        name = "Морская"
      when "深海"
        name = "Глубоководная"
      when "洞窟"
        name = "Пещерная"
      when "市街"
        name = "Городская"
      else
        name = "Нет"
      end
      return "#{name} #{0.2 < ft.value ? "Супер-" : ""}Сила"
    end

    #--------------------------------------------------------------------------
    # ● 物理反射率名を取得
    #--------------------------------------------------------------------------
    def physical_reclection_name(ft)
      rate = (ft.value * 100.0).to_i
      "Отражение Атак #{0 < rate ? '+' : '-'}#{rate.abs}%"
    end

    #--------------------------------------------------------------------------
    # ● 装備マスタリー名を取得
    #--------------------------------------------------------------------------
    def equip_mastery_name(ft)
      "Мастерство"
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
              "Неизб."
            when HitType::MAGICAL
              "Маг."
            when HitType::PHYSICAL
              "Физ."
            end
      "Блок #{pre} Атак = #{(ft.value * 100).to_i}%"
    end

    def booster_critical_name(ft)
      "Крит. Урон +#{(ft.value * 100).to_i}%"
    end
  end
end
