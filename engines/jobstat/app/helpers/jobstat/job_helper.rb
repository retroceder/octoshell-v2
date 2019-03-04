module Jobstat
  module JobHelper
    def format_float_or_nil(value)
      if value.nil?
        ""
      else
        "%.2f" % value.round(2)
      end
    end

    def get_one_rank(value, *arr)
      if value.nil?
        return ""
      end

      while arr.size>0
        name=arr.shift
        if arr.size==0
          return name
        else
          return name if value < arr.shift
        end
      end
    end

    def get_involved_projects(user)
      # get hash with projects and logins for user
      # include all personal logins for projects, where user is involved


      result = Hash.new {|hash, key| hash[key] = []}

      projects_with_participation = user.projects.where.not(id: (user.owned_projects.pluck(:id) \
         | user.projects_with_invitation.pluck(:id))) # TODO ???

      projects_with_participation.each do |project|
        project.members.each do |member|
          if member.user_id == user.id
            result[project].push(member.login)
          end
        end
      end

      result
    end

    def get_owned_projects(user)
      # get hash with projects and logins for user
      # include all logins from owned projects

      result = Hash.new {|hash, key| hash[key] = []}

      user.owned_projects.each do |project|
        project.members.each do |member|
          result[project].push(member.login)
        end
      end

      result
    end

    def get_owned_logins
      owned_projects = get_owned_projects(current_user)
      owned_projects.map {|_, value| value}.uniq
      #FIXME! Just for test
      ["vadim", "shvets", "vurdizm", "wasabiko", "ivanov", "afanasievily_251892", "gumerov_219059"]
    end

    def get_involved_logins
      involved_projects = get_involved_projects(current_user)
      involved_projects.values.uniq
      #FIXME! Just for test
      ["vadim"]
    end

    def get_all_projects
      all_projects=get_owned_projects(current_user)
      all_projects.merge!(get_involved_projects(current_user)){|key,old_val,new_val|
        old_val.concat(new_val).uniq
      }      
    end

    def get_expert_projects
      project_ids = Sessions::Report.where(expert_id: current_user.id)
        .where(state: 'assessing').where('created_at > ?', Date.today.strftime("%Y.01.01")).pluck(:project_id)
      projects = Core::Project.where(id: project_ids)

      result = Hash.new {|hash, key| hash[key] = []}
      projects.each do |project|
        project.members.each do |member|
          result[project].push(member.login)
        end
      end

      result
    end

    def get_select_options_by_projects projects, selected=[]
      list=[]
      dis=[]
      projects.each{|proj,logins|
        p="---- #{shorten(proj.title,32)} ----"
        list << p
        dis << p
        list.concat(logins)
      }
      [list, {selected: selected, disabled: dis}]
      #debug [["-- RNF --","vadim", "shvets", "-- Worlid domination --", "vurdizm", "wasabiko", "ivanov", "-- Postgraduate play --", "afanasievily_251892", "gumerov_219059"], selected: selected, disabled: ["-- RNF --","-- Worlid domination --","-- Postgraduate play --"]]
      #options_for_select(list, selected: selected, disabled: dis)
    end

    def shorten name, len
      l=name.length
      if l>len
        "#{name[0 .. l/2-1]}..#{name[l/2+1 .. l]}"
      else
        name
      end
    end
  end
end
