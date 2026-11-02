import 'package:ai_study_buddy/vu_v2/business_career/business_career_content.dart';
import 'package:ai_study_buddy/vu_v2/business_career/biz_job_catalog.dart';
import 'package:ai_study_buddy/vu_v2/business_career/case_challenge_bank.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('budget allocations that sum to 80k produce finite KPIs', () {
    final CompanyKpis after = DecliningCompanyEngine.simulate(
      strategy: RecoveryStrategy.balancedTurnaround,
      retentionSpend: 30000,
      opsSpend: 25000,
      productSpend: 25000,
    );
    expect(after.customers, greaterThan(0));
    expect(after.monthlyRevenue, greaterThan(0));
    expect(after.satisfaction, inInclusiveRange(0.2, 0.98));
    expect(after.cash, lessThan(CompanyKpis.decliningBaseline.cash));
  });

  test('cost cutting lowers customers vs retention strategy', () {
    final CompanyKpis cut = DecliningCompanyEngine.simulate(
      strategy: RecoveryStrategy.costCutting,
      retentionSpend: 10000,
      opsSpend: 60000,
      productSpend: 10000,
    );
    final CompanyKpis retain = DecliningCompanyEngine.simulate(
      strategy: RecoveryStrategy.customerRetention,
      retentionSpend: 60000,
      opsSpend: 10000,
      productSpend: 10000,
    );
    expect(retain.customers, greaterThan(cut.customers));
  });

  test('all eight majors have case challenges and jobs', () {
    for (final BusinessMajor m in BusinessMajors.all) {
      expect(
        CaseChallengeBank.forMajor(m.id),
        isNotEmpty,
        reason: 'challenges for ${m.id}',
      );
      expect(
        BizCareerJobs.all.where((BizJobListing j) => j.majorTag == m.title),
        isNotEmpty,
        reason: 'jobs for ${m.title}',
      );
    }
  });

  test('flagship Apex Commerce job exists', () {
    final BizJobListing? job =
        BizCareerJobs.byId(BizCareerJobs.flagshipJobId);
    expect(job, isNotNull);
    expect(job!.company, 'Apex Commerce');
    expect(job.hourlyWageCents, 2600);
  });
}
