package kr.or.ddit.mybatis.mappers.evaluation;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import kr.or.ddit.evaluation.vo.EvaluationChartVO;
import kr.or.ddit.evaluation.vo.EvaluationDashboardSummaryVO;
import kr.or.ddit.evaluation.vo.EvaluationDashboardVO;
import kr.or.ddit.evaluation.vo.EvaluationDepartmentSummaryVO;
import kr.or.ddit.evaluation.vo.EvaluationSummaryVO;
import kr.or.ddit.evaluation.vo.RankScoreVO;
import kr.or.ddit.evaluation.vo.UnsubmittedEmployeeVO;

@Mapper
public interface EvaluationDashboardMapper {

	// 대쉬보드 상세 1
	List<EvaluationDepartmentSummaryVO> getDepartmentSummary(@Param("evaluationYear") String evaluationYear,
			@Param("halfYear") String halfYear);
	
	// 대쉬보드 상세 2
	List<EvaluationDashboardVO> getDepartmentTeamEvaluationStatus(
			@Param("evaluationYear") String evaluationYear,
			@Param("halfYear") String halfYear);

	// 대쉬보드 요약
	EvaluationDashboardSummaryVO getEvaluationSummary(
			@Param("evaluationYear") String evaluationYear,
			@Param("halfYear") String halfYear);
	
	// 차트용
	List<EvaluationChartVO> getDepartmentEvaluationChart(
			@Param("evaluationYear") String evaluationYear,
            @Param("halfYear") String halfYear);
	
	// 미평가자 명단
	List<UnsubmittedEmployeeVO> getUnsubmittedList(
			@Param("evaluationYear") String evaluationYear,
            @Param("halfYear") String halfYear,
            @Param("teamId") String teamId);

}
