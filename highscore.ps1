<#
.SYNOPSIS
    Manage a game player's High Score list.

.DESCRIPTION
    Your task is to build a high-score component of the classic Frogger game, one of the highest selling and most addictive games of all time, and a classic of the arcade era.
    Your task is to write methods that return the highest score from the list, the last added score and the three highest scores.

.EXAMPLE
    $roster = [HighScores]::new(@(30, 50, 40, 90, 80))
    $roster.GetTopThree()
    return : @(90, 80, 50)
#>
Class HighScores {
    [int[]]$scores
    HighScores([int[]]$list){
        $this.scores = $list
    }
    [int[]]GetScores(){
        return $this.scores
    }
    [int]GetLatest() {
        return $this.scores[-1]
    }

    [int]GetPersonalBest(){
        return($this.scores |Measure-Object -Maximum).Maximum
    }

    [int[]] GetTopThree(){
        return $this.scores | Sort-Object -Descending | Select-Object -First 3
    }
}

[HighScores]::New(@(80))
$scores.GetTopThree()