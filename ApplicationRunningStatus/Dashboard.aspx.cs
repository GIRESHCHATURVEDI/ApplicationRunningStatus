using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.ServiceProcess;
using System.Configuration;
using System.Diagnostics;
using System.Web.UI.HtmlControls;
using System.Net;

namespace ApplicationRunningStatus
{
    public partial class Dashboard : System.Web.UI.Page
    {

        string sqlServiceName = ConfigurationManager.AppSettings["SQLinstance"];
        string Arinc_SAC = ConfigurationManager.AppSettings["ARINC"];
        string PLC_Dom = ConfigurationManager.AppSettings["PLC_Dom"];
        string PLC_Int = ConfigurationManager.AppSettings["PLC_Int"];
        string PLC_MES = ConfigurationManager.AppSettings["PLC_MES"];
        string PLC_REJ = ConfigurationManager.AppSettings["PLC_REJ"];

        string SAC_ALLOCATION = ConfigurationManager.AppSettings["SAC_ALLOCATION"];
        string AODB = ConfigurationManager.AppSettings["AODBinstance"];

        int IsArincCommunicationWorking = 0;
        int IsPLC_DomWorking = 0;
        int IsPLC_IntWorking = 0;
        int IsPLC_MESworking = 0;
        int IsPLC_REJworking = 0;
        int IsSql_Working = 0;
        int IsAODB_Working = 0;  


        protected void Page_Load(object sender, EventArgs e)
        {
           
                  
         
        }
        private void sqlStatus()
        {
            // this method will check if the sql services are running or not.
            string status;
            ServiceController mySC = new ServiceController(sqlServiceName);
            try
            {
                status = mySC.Status.ToString();
            }
            catch (Exception ex)
            {
                status = ex.Message;
            }
            if (status.Equals("Running"))
            {
                IsSql_Working = 1;
            }
            else
            {
                IsSql_Working = 0;
            }
        }
        public void IsProcessOpen()
        {

            foreach (Process clsProcess in Process.GetProcesses())
            {
                if (clsProcess.ProcessName.Contains(Arinc_SAC))
                {
                    IsArincCommunicationWorking = 1;
                }
                else if (clsProcess.ProcessName.Contains(PLC_Dom))
                {
                    IsPLC_DomWorking = 1;
                }
                else if (clsProcess.ProcessName.Contains(PLC_Int))
                {
                    IsPLC_IntWorking = 1;
                }
                else if (clsProcess.ProcessName.Contains(AODB))
                {
                    IsAODB_Working = 1;
                }
                else if (clsProcess.ProcessName.Contains(PLC_MES))
                {
                    IsPLC_MESworking = 1;
                }
                else if (clsProcess.ProcessName.Contains(PLC_REJ))
                {
                    IsPLC_REJworking = 1;
                }

            }
        }
        protected void Timer1_Tick(object sender, EventArgs e)
        {
            IsProcessOpen();

            Image img = (Image)FindControl("img_AODB_Interface");
            Label lbl = (Label)FindControl("lbl_AODB");
            string url = IsAODB_Working == 1 ? "Images/Green_Background.jpg" : "Images/Red_Background.jpg";
            img.ImageUrl = url;
            lbl.Text= IsAODB_Working == 1 ? "RUNNING" : "STOPPED";

            img = (Image)FindControl("img_Arinc_Sac");
            lbl = (Label)FindControl("lbl_Arinc");
            url = IsArincCommunicationWorking == 1 ? "Images/Green_Background.jpg" : "Images/Red_Background.jpg";
            img.ImageUrl = url;
            lbl.Text = IsArincCommunicationWorking == 1 ? "RUNNING" : "STOPPED";

            img = (Image)FindControl("img_PLC_SAC_Domestic");
            lbl = (Label)FindControl("lbl_PLC_Dom");
            url = IsPLC_DomWorking == 1 ? "Images/Green_Background.jpg" : "Images/Red_Background.jpg";
            img.ImageUrl = url;
            lbl.Text = IsPLC_DomWorking == 1 ? "RUNNING" : "STOPPED";


            img = (Image)FindControl("img_PLC_SAC_International");
            lbl = (Label)FindControl("lbl_PLC_Int");
            url = IsPLC_IntWorking == 1 ? "Images/Green_Background.jpg" : "Images/Red_Background.jpg";
            img.ImageUrl = url;
            lbl.Text = IsPLC_IntWorking == 1 ? "RUNNING" : "STOPPED";

            img = (Image)FindControl("img_MES");
            lbl = (Label)FindControl("lbl_PLC_Mes");
            url = IsPLC_MESworking == 1 ? "Images/Green_Background.jpg" : "Images/Red_Background.jpg";
            img.ImageUrl = url;
            lbl.Text = IsPLC_MESworking == 1 ? "RUNNING" : "STOPPED";

            img = (Image)FindControl("img_REJ");
            lbl = (Label)FindControl("lbl_PLC_Rej");
            url = IsPLC_REJworking == 1 ? "Images/Green_Background.jpg" : "Images/Red_Background.jpg";
            img.ImageUrl = url;
            lbl.Text = IsPLC_REJworking == 1 ? "RUNNING" : "STOPPED";

            sqlStatus();

            img = (Image)FindControl("img_Sql_status");
            lbl = (Label)FindControl("lbl_SQL_Server");
            url = IsSql_Working == 1 ? "Images/Green_Background.jpg" : "Images/Red_Background.jpg";
            img.ImageUrl = url;            
            lbl.Text = IsSql_Working == 1 ? "RUNNING" : "STOPPED";

            img_SAC_Allocation.ImageUrl = "Images/Green_Background.jpg";
        }

    }
}