#
# もんむす・くえすと！ＲＰＧ
# 　セーブデータ異常修正 ver2  2015/03/29
#
# 機能一覧　説明は下　このverで新規追加したものは●　変更したものは○　削除は×
# ・スキルをアビリティとして習得していた場合、忘却してからスキルとして習得
# ×冥府再戦敗北での一部アクターの離脱を無効（再戦かどうかは変数で判定）
# ×冥府再戦敗北での一部アクターの離脱が発生していた場合、加入（同じく変数で判定）
#

#==============================================================================
# ■ Game_Temp
#==============================================================================
class Game_Temp
  #--------------------------------------------------------------------------
  # ● bugfixフラグを取得　されていない場合はフラグをオン
  #--------------------------------------------------------------------------
  def bugfixed?(key)
    @bugfix ||= {}
    if @bugfix[key]
      true
    else
      @bugfix[key] = true
      false
    end
  end

  #--------------------------------------------------------------------------
  # ● bugfixフラグをクリア
  #--------------------------------------------------------------------------
  def clear_bugfix_flag
    @bugfix = {}
  end
end

#==============================================================================
# ■ Game_Actor
#==============================================================================
class Game_Actor < Game_Battler
  #--------------------------------------------------------------------------
  # ● アビリティのスキルタイプ修正
  #--------------------------------------------------------------------------
  def bugfix_learned_ability_type
    return if $game_temp.bugfixed?([:actor_learned_ability_type, id])

    NWConst::Ability::ABILITY_SKILL_TYPE.each do |ability_stype_id|
      @abilities[ability_stype_id].each do |skill_id|
        next if ability_stype_id == $data_skills[skill_id].stype_id && $data_skills[skill_id].ability?

        @abilities[ability_stype_id].delete(skill_id)
        @equip_abilities[ability_stype_id].delete(skill_id)
        learn_skill(skill_id)
      end
    end
  end

  #--------------------------------------------------------------------------
  # ● スキル削除
  #--------------------------------------------------------------------------
  def bugfix_skills
    return if $game_temp.bugfixed?([:actor_skill, id])

    @skills.select! { |skill_id| skill_learnable?($data_skills[skill_id]) && $data_skills[skill_id] && $data_skills[skill_id].stype_id != 0}
    @skills.each do |skill_id|
      next unless $data_skills[skill_id].ability?

      @skills.delete(skill_id)
      learn_skill(skill_id)
    end
  end
end
