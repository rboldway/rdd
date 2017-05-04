module Rdd

  class << self

    private

    def CreateEvent(event)
      if event && event["payload"]["ref_type"] == "repository"
        {repo: {id: event["repo"]["id"], name: event["repo"]["name"]}, points: 10}
      end
    end

    def ForkEvent(event)
      if event && event["forkee"]
        {repo: {id: event["repo"]["id"], name: event["repo"]["name"]}, points: 5}
      end
    end

    def MemberEvent(event)
      if event && event["payload"]["action"] == "added"
        {repo: {id: event["repo"]["id"], name: event["repo"]["name"]}, points: 2}
      end
    end

    def PullRequestEvent(event)
      if event && event["payload"]["action"] == "closed" && event["merged_at"] != nil
        {repo: {id: event["repo"]["id"], name: event["repo"]["name"]}, points: 2}
      end
    end

    def IssuesEvent(event)
      if event && event["payload"]["action"] == "opened"
        {repo: {id: event["repo"]["id"], name: event["repo"]["name"]}, points: 1}
      end
    end

    def WatchEvent(event)
      if event && event["payload"]["action"] == "started"
        {repo: {id: event["repo"]["id"], name: event["repo"]["name"]}, points: 1}
      end
    end

  end

end