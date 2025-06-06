package kr.or.ddit.evaluation.service;

import java.time.LocalDate;
import java.util.List;

import javax.inject.Inject;

import org.springframework.stereotype.Service;

import kr.or.ddit.evaluation.vo.EvaluationTypeVO;
import kr.or.ddit.mybatis.mappers.evaluation.evaluationTypeMapper;
import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class EvaluationTypeServiceImpl implements EvaluationTypeService {


	@Inject
	private evaluationTypeMapper dao;
	
	@Override
	public List<EvaluationTypeVO> evaluTypeList(String evaluationYear, String halfYear) {
	    return dao.evaluTypeList(evaluationYear, halfYear);
	}

	@Override
	public List<EvaluationTypeVO> evaluationRank(String evaluationYear, String halfYear) {
		return dao.evaluationRank(evaluationYear, halfYear);
		
	}
		
	@Override
	public void insertEvaluType(EvaluationTypeVO evaluType) {
		dao.insertEvaluType(evaluType);

	}

	@Override
    public int deleteEvaluType(String evaluTypeId) {
        return dao.deleteEvaluType(evaluTypeId);
    }

//    @Override
//    public EvaluationTypeVO selectEvaluTypeById(String evaluTypeId) {
//        return dao.selectEvaluTypeById(evaluTypeId);
//    }
}