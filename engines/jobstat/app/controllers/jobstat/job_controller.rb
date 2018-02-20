require_dependency "jobstat/application_controller"

module Jobstat
  class JobController < ApplicationController
    include JobHelper

    @@tags = {
        :cls_communicative_volume => "receive or transmitted data > 500MB/s",
        :cls_communicative_packets => "receive or transmitted packets > 300k/s",
        :cls_sc_appropriate => "high data transmission rate and fitting loadavg",
        :cls_not_communicative => "multi-node job with low network activity",
        :cls_serial => "single node, single process jobs",
        :cls_suspicious => "low cpu load, low loadavg, low gpu load",
        :cls_data_intensive => "high memory activity",
        :cls_gpu_pure => "high gpu load, low cpu load",
        :cls_gpu_hybrid_good => "high gpu load, high cpu load",
        :cls_single => "single node jobs",
        :cls_locality_good => "good l1 and not bad l23 or good l23 and not bad l1",
        :cls_locality_bad => "bad l1 and not good l23 or bad l23 and not good l1",
        :cls_locality_weird => "good l1 and bad l23 or good l23 and bad l1",
        :short => "less than 15 minutes"
    }

    def show
      @job = Job.find(params[:id])
      @job_perf = @job.get_performance
      @ranking = @job.get_ranking
      @job_tags = @job.get_tags
      @tags = @@tags
    end


    def post_info
      drms_job_id = params[:job_id]
      drms_task_id = params.fetch(:task_id, 0)

      Job.where(drms_job_id: drms_job_id, drms_task_id: drms_task_id).first_or_create
          .update({cluster: params[:cluster],
                   login: params[:account],
                   partition: params[:partition],
                   submit_time: Time.at(params[:t_submit]).utc.to_datetime,
                   start_time: Time.at(params[:t_start]).utc.to_datetime,
                   end_time: Time.at(params[:t_end]).utc.to_datetime,
                   timelimit: params[:timelimit],
                   command: params[:command],
                   state: params[:state],
                   num_cores: params[:num_cores],
                  })
    end

    def post_performance
      drms_job_id = params[:job_id]
      drms_task_id = params.fetch(:task_id, 0)

      job = Job.where(drms_job_id: drms_job_id, drms_task_id: drms_task_id).first()

      FloatDatum.where(job_id: job.id, name: "cpu_user").first_or_create
          .update({value: params["avg"]["cpu_user"]})
      FloatDatum.where(job_id: job.id, name: "gpu_load").first_or_create
          .update({value: params["avg"]["gpu_load"]})
      FloatDatum.where(job_id: job.id, name: "loadavg").first_or_create
          .update({value: params["avg"]["loadavg"]})

      if params["avg"].key?("ib_rcv_data")
        FloatDatum.where(job_id: job.id, name: "ib_rcv_data").first_or_create
            .update({value: params["avg"]["ib_rcv_data"]})
        FloatDatum.where(job_id: job.id, name: "ib_xmit_data").first_or_create
            .update({value: params["avg"]["ib_xmit_data"]})
      elsif params["avg"].key?("ib_rcv_data_mpi")
        FloatDatum.where(job_id: job.id, name: "ib_rcv_data").first_or_create
            .update({value: params["avg"]["ib_rcv_data_mpi"] + params["avg"]["ib_rcv_data_fs"]})
        FloatDatum.where(job_id: job.id, name: "ib_xmit_data").first_or_create
            .update({value: params["avg"]["ib_xmit_data_mpi"] + params["avg"]["ib_xmit_data_fs"]})
      end
    end
  end
end
