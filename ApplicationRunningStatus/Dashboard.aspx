<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Dashboard.aspx.cs" Inherits="ApplicationRunningStatus.Dashboard" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="description" content="">
    <meta name="author" content="">
    <title>SAC Services Status</title>
    <!-- Bootstrap Core CSS -->
    <link href="css/bootstrap.min.css" rel="stylesheet">
    <!-- Custom CSS -->
    <link href="css/heroic-features.css" rel="stylesheet">
</head>
<body>
    <form id="form1" runat="server">
        <asp:Timer ID="Timer1" runat="server" Interval="5000" runat="server" OnTick="Timer1_Tick">
        </asp:Timer>
        <!-- Page Content -->

        <%--<img src="Images/Logo_BEUMERGROUP_Originalfarbe_RGB.png"/>--%>
        <div class="container">
            <!-- Jumbotron Header -->
            <header class="page-header">
            <h1>SAC Services Status</h1>           
        </header>
            <!-- Title -->
            <!-- /.row -->
            <!-- Page Features -->
            <div class="row text-center">

                <div class="col-md-3 col-sm-4 hero-feature">
                    <div class="thumbnail">
                        <asp:Image ID="img_PLC_SAC_Domestic" runat="server" alt="" />
                        <div class="caption">
                            <h3>PLC-01(Comm.)</h3>
                            <asp:Label ID="lbl_PLC_Dom" runat="server" Text="RUNNING"></asp:Label>
                        </div>
                    </div>
                </div>
                <div class="col-md-3 col-sm-4 hero-feature">
                    <div class="thumbnail">
                        <%--<img src="Images/Green_Background.jpg" alt="" id="img_PLC_SAC_International" runat="server"/>--%>
                        <asp:Image ID="img_PLC_SAC_International" runat="server" alt="" />
                        <div class="caption">
                            <h3>PLC-02(Comm.)</h3>
                            <asp:Label ID="lbl_PLC_Int" runat="server" Text="RUNNING"></asp:Label>
                        </div>
                    </div>
                </div>

                <div class="col-md-3 col-sm-4 hero-feature">
                    <div class="thumbnail">
                        <%--<img src="Images/Green_Background.jpg" alt="" id="img_PLC_SAC_International" runat="server"/>--%>
                        <asp:Image ID="img_MES" runat="server" alt="" />
                        <div class="caption">
                            <h3>PLC-MES(Comm.)</h3>
                            <asp:Label ID="lbl_PLC_Mes" runat="server" Text="RUNNING"></asp:Label>
                        </div>
                    </div>
                </div>

                <div class="col-md-3 col-sm-4 hero-feature">
                    <div class="thumbnail">
                        <%--<img src="Images/Green_Background.jpg" alt="" id="img_PLC_SAC_International" runat="server"/>--%>
                        <asp:Image ID="img_REJ" runat="server" alt="" />
                        <div class="caption">
                            <h3>PLC-REJ(Comm.)</h3>
                            <asp:Label ID="lbl_PLC_Rej" runat="server" Text="RUNNING"></asp:Label>
                        </div>
                    </div>
                </div>
                <div class="col-md-3 col-sm-4 hero-feature">
                    <div class="thumbnail">
                        <asp:Image ID="img_Arinc_Sac" runat="server" alt="" />
                        <div class="caption">
                            <h3>ARINC-SAC</h3>
                            <asp:Label ID="lbl_Arinc" runat="server" Text="RUNNING"></asp:Label>
                        </div>
                    </div>
                </div>
                <div class="col-md-3 col-sm-4 hero-feature">
                    <div class="thumbnail">
                        <asp:Image ID="img_AODB_Interface" runat="server" alt="" />
                        <%--<img src="Images/Green_Background.jpg" alt="" id="img_SAC_Allocation" runat="server"/>--%>
                        <div class="caption">
                            <h3>AODB INTERFACE</h3>
                            <asp:Label ID="lbl_AODB" runat="server" Text="RUNNING"></asp:Label>
                        </div>
                    </div>
                </div>

                <div class="col-md-3 col-sm-4 hero-feature">
                    <div class="thumbnail">
                        <asp:Image ID="img_SAC_Allocation" runat="server" alt="" />
                        <div class="caption">
                            <h3>SAC ALLOCATION</h3>
                            <asp:Label ID="lbl_SAC_Allocation" runat="server" Text="RUNNING"></asp:Label>
                        </div>
                    </div>
                </div>

                <div class="col-md-3 col-sm-4 hero-feature">
                    <div class="thumbnail">
                        <asp:Image ID="img_Sql_status" runat="server" alt="" />
                        <div class="caption">
                            <h3>SQL SERVER</h3>
                            <asp:Label ID="lbl_SQL_Server" runat="server" Text="RUNNING"></asp:Label>
                        </div>
                    </div>
                </div>

            </div>
            <!-- /.row -->
            <hr>
            <!-- Footer -->
            <footer>
            <div class="row">
                <div class="col-lg-12">
                    <p>Copyright &copy; 2018, BEUMER GROUP </p>                    
                </div>
            </div>
        </footer>
            <asp:ScriptManager ID="Scriptmanager1" runat="server">
            </asp:ScriptManager>
        </div>
        <!-- /.container -->
        <!-- jQuery -->
        <script src="js/jquery.js"></script>
        <!-- Bootstrap Core JavaScript -->
        <script src="js/bootstrap.min.js"></script>
    </form>
</body>
</html>
